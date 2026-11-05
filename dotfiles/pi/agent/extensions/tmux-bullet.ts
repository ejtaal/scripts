import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { createLocalBashOperations, type BashOperations } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  let activeCount = 0;
  let idleTitle: string;
  const cp = require("child_process");

  function setTmuxTitle(title: string) {
    const escaped = title.replace(/'/g, "'\"'\"'");
    const pane = process.env.TMUX_PANE;
    if (!pane) return;
    cp.exec(`tmux rename-window -t '${pane}' '${escaped}'`);
  }

  // Resolve git repo basename from cwd
  function gitRepoBasename(): string {
    try {
      const toplevel = cp.spawnSync("git", ["rev-parse", "--show-toplevel"], {
        encoding: "utf-8",
      });
      if (toplevel.status === 0 && toplevel.stdout.trim()) {
        return cp.execSync(`basename "${toplevel.stdout.trim()}"`, { encoding: "utf-8" }).trim();
      }
    } catch {
      const cwd = process.cwd();
      return cwd.split("/").pop() ?? "pi";
    }
    return "pi";
  }

  pi.on("session_start", async (_event, _ctx) => {
    const repo = gitRepoBasename();
    idleTitle = `\u03c0 ${repo}`; // π symbol
  });

  // --- Agent runs ---
  pi.on("before_agent_start", async (_event, _ctx) => {
    activeCount++;
    setTmuxTitle(`\u25cf ${idleTitle}`); // ● prefix
  });

  pi.on("agent_settled", async (_event, _ctx) => {
    activeCount = Math.max(0, activeCount - 1);
    if (activeCount === 0) {
      setTmuxTitle(idleTitle);
    }
  });

  // --- Compaction ---
  pi.on("session_before_compact", async (_event, _ctx) => {
    activeCount++;
    setTmuxTitle(`\u25cf ${idleTitle}`);
  });

  pi.on("session_compact", async (_event, _ctx) => {
    activeCount = Math.max(0, activeCount - 1);
    if (activeCount === 0) {
      setTmuxTitle(idleTitle);
    }
  });

  pi.on("session_compact_failed", async (_event, _ctx) => {
    activeCount = Math.max(0, activeCount - 1);
    if (activeCount === 0) {
      setTmuxTitle(idleTitle);
    }
  });

  // --- User bash commands (! / !!) ---
  pi.on("user_bash", async (event, _ctx) => {
    const localOps = createLocalBashOperations();
    activeCount++;
    setTmuxTitle(`\u25cf ${idleTitle}`);

    const trackedOps: BashOperations = {
      exec: (command: string, cwd?: string, options?: any) => {
        return localOps.exec(command, cwd, options).then((result) => {
          activeCount = Math.max(0, activeCount - 1);
          if (activeCount === 0) {
            setTmuxTitle(idleTitle);
          }
          return result;
        });
      },
      cleanup: (sessionId: string) => localOps.cleanup(sessionId),
      killSession: (sessionId: string) => localOps.killSession(sessionId),
    };

    return { operations: trackedOps };
  });

  pi.on("session_shutdown", async (_event, _ctx) => {
    activeCount = 0;
  });
}
