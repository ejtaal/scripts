import { Plugin } from "@opencode/plugin/tui"
import { createSignal, Show, createComputed } from "solid-js"
import { exec } from "child_process"
import { promisify } from "util"

const execAsync = promisify(exec)

type State = "idle" | "thinking"
const EMOJIS: Record<State, string> = { idle: "", thinking: "\u25cf" }

function StateLabel(s: State): string {
  return s === "idle" ? "" : "thinking\u2026"
}

function RepoBasename(locationDir: string): string {
  return locationDir.split("/").filter(Boolean).pop() || "."
}

function BuildTitle(state: State, basename: string): string {
  const prefix = EMOJIS[state]
  const prefixPart = prefix ? `${prefix} ` : ""
  return `${prefixPart}OC: ${basename}`
}

async function SetTmuxTitle(title: string): Promise<void> {
  if (!process.env.TMUX || !process.env.TMUX_PANE) return
  const socketPath = process.env.TMUX.split(",")[0]
  await execAsync(`tmux -S "${socketPath}" rename-window -t ${process.env.TMUX_PANE} "${title}"`)
}

// Status may be a SessionStatus object ({ type: "busy" }) or a plain type string.
function IsBusyStatus(status: unknown): boolean {
  const type =
    typeof status === "object" && status
      ? (status as { type?: string }).type
      : (status as string | undefined)
  return type === "busy" || type === "retry" || type === "running"
}

export default Plugin.define({
  id: "opencode-tmux-title",
  setup(context) {
    const [state, setState] = createSignal<State>("idle")
    const [enabled, setEnabled] = createSignal(true)
    const [basename, setBasename] = createSignal<string>(".")
    let pollInterval: ReturnType<typeof setInterval> | null = null

    const loc = context.location ?? context.data.location.default()
    if (loc?.directory) {
      setBasename(RepoBasename(loc.directory))
    }

    // --- Scope to the session this TUI (this tmux window) is viewing. ---

    // The router is local to this TUI instance, so its route identifies exactly
    // the session shown in this window. Subagents belong to the viewed session's
    // family, so their activity counts as this session.
    function ViewedSessionID(): string | undefined {
      try {
        const route = context.ui.router.current() as
          | { type?: string; sessionID?: string }
          | undefined
        if (route?.type !== "session" || !route.sessionID) return undefined
        return route.sessionID
      } catch {
        return undefined
      }
    }

    function SafeRoot(sessionID: string): string | undefined {
      try {
        return context.data.session.root(sessionID) ?? sessionID
      } catch {
        return undefined
      }
    }

    function BelongsToViewed(sessionID: string): boolean {
      const viewed = ViewedSessionID()
      if (!viewed) return false
      return SafeRoot(sessionID) === viewed || sessionID === viewed
    }

    // --- State evaluation over only the viewed session's family. ---
    function RefreshState(): void {
      if (!enabled()) return
      const viewed = ViewedSessionID()
      let busy = false
      if (viewed) {
        const sessions = context.data.session.list()
        if (Array.isArray(sessions)) {
          for (const s of sessions) {
            const sid = typeof s === "object" ? s.id : s
            if (sid !== viewed && SafeRoot(sid) !== viewed) continue
            if (IsBusyStatus(context.data.session.status(sid))) {
              busy = true
              break
            }
          }
        }
      }
      setState(busy ? "thinking" : "idle")
    }

    function ApplyState(): void {
      if (enabled()) SetTmuxTitle(BuildTitle(state(), basename()))
    }

    // Re-derive state on initial mount and every time the viewed session changes.
    createComputed(() => {
      ViewedSessionID()
      RefreshState()
    })

    // Fast path from events — but only for sessions belonging to this window.
    const onStatus = context.data.on(
      "session.status",
      (event: { properties?: { sessionID?: string; status?: unknown } }) => {
        if (!enabled()) return
        const sessionID = event.properties?.sessionID
        if (!sessionID || !BelongsToViewed(sessionID)) return
        setState(
          IsBusyStatus(event.properties?.status) ? "thinking" : "idle",
        )
      },
    )

    const onIdle = context.data.on(
      "session.idle",
      (event: { properties?: { sessionID?: string } }) => {
        if (!enabled()) return
        const sessionID = event.properties?.sessionID
        if (!sessionID || !BelongsToViewed(sessionID)) return
        setState("idle")
      },
    )

    const cleanupFns = [onStatus, onIdle]

    function StartPolling(): void {
      if (pollInterval) return
      RefreshState()
      ApplyState()
      pollInterval = setInterval(() => {
        RefreshState()
        ApplyState()
      }, 2000)
    }

    function StopPolling(): void {
      if (pollInterval) { clearInterval(pollInterval); pollInterval = null }
    }

    if (enabled()) StartPolling()

    context.keymap.layer(() => ({
      mode: "global",
      commands: [
        {
          id: "tmux-title.toggle",
          title: "Toggle tmux title updates",
          group: "Tmux Title",
          slash: { name: "tmux-title", aliases: ["tt"] },
          run: () => {
            const next = !enabled()
            setEnabled(next)
            if (next) {
              StartPolling()
              context.ui.toast.show({ message: "Tmux title updates enabled", variant: "success" })
            } else {
              StopPolling()
              setState("idle")
              SetTmuxTitle(BuildTitle("idle", basename()))
              context.ui.toast.show({ message: "Tmux title updates disabled", variant: "info" })
            }
          },
        },
      ],
      bindings: ["tmux-title.toggle"],
    }))

    const unregister = context.ui.slot({
      append: "home.footer.status",
      render: () => (
        <Show when={enabled() && state() !== "idle"}>
          <text>
            {" "}
            <text fg={context.theme.status.info}>
              {EMOJIS[state()]} {StateLabel(state())}
            </text>
          </text>
        </Show>
      ),
    })

    return () => {
      cleanupFns.forEach((fn) => fn())
      StopPolling()
      unregister()
      SetTmuxTitle(BuildTitle("idle", basename()))
    }
  },
})
