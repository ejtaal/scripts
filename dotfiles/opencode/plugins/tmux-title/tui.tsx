import { Plugin } from "@opencode/plugin/tui"
import { createSignal, Show } from "solid-js"
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

export default Plugin.define({
  id: "opencode-tmux-title",
  setup(context) {
    const [state, setState] = createSignal<State>("idle")
    const [enabled, setEnabled] = createSignal(true)
    const [basename, setBasename] = createSignal<string>(".")
    let pollInterval: ReturnType<typeof setInterval> | null = null
    let currentBasename = "."

    const loc = context.location ?? context.data.location.default()
    if (loc?.directory) {
      currentBasename = RepoBasename(loc.directory)
      setBasename(currentBasename)
    }

    if (enabled()) {
      SetTmuxTitle(BuildTitle("idle", currentBasename))
    }

    const onStatus = context.data.on(
      "session.status",
      (event: { properties: { status: { type: string } } }) => {
        if (event.properties.status.type === "busy") {
          setState("thinking")
          if (enabled()) SetTmuxTitle(BuildTitle("thinking", currentBasename))
        }
      },
    )

    const onIdle = context.data.on("session.idle", () => {
      setState("idle")
      if (enabled()) SetTmuxTitle(BuildTitle("idle", currentBasename))
    })

    const cleanupFns = [onStatus, onIdle]

    const poll = () => {
      if (!enabled()) return
      const sessions = context.data.session.list()
      if (!Array.isArray(sessions) || sessions.length === 0) return

      let anyBusy = false
      for (const s of sessions) {
        const sid = typeof s === "object" ? s.id : s
        const status = context.data.session.status(sid)
        if (status === "busy" || status === "retry" || status === "running") {
          anyBusy = true
          break
        }
      }

      const newState: State = anyBusy ? "thinking" : "idle"
      if (newState !== state()) {
        setState(newState)
        if (enabled()) SetTmuxTitle(BuildTitle(newState, currentBasename))
      }
    }

    const startPolling = () => {
      poll()
      pollInterval = setInterval(poll, 2000)
    }

    const stopPolling = () => {
      if (pollInterval) { clearInterval(pollInterval); pollInterval = null }
      cleanupFns.forEach((fn) => fn())
      cleanupFns.length = 0
    }

    if (enabled()) startPolling()

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
              startPolling()
              SetTmuxTitle(BuildTitle(state(), currentBasename))
              context.ui.toast.show({ message: "Tmux title updates enabled", variant: "success" })
            } else {
              stopPolling()
              SetTmuxTitle(BuildTitle("idle", currentBasename))
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
      stopPolling()
      unregister()
      if (enabled()) SetTmuxTitle(BuildTitle("idle", currentBasename))
    }
  },
})
