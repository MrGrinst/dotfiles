#!/usr/bin/env bun
import { statSync, readdirSync, realpathSync, rmSync } from "node:fs";
import { basename, dirname } from "node:path";

declare const Bun: {
  spawnSync(argv: string[], opts: object): {
    exitCode: number | null;
    stdout: { toString(): string } | null;
  };
};

export interface ExecResult {
  code: number;
  stdout: string;
}

/** Every subprocess and filesystem touch goes through this seam so routing is testable. */
export interface Sys {
  exec(argv: string[]): ExecResult;
  listSockets(): string[];
  statMtime(path: string): number;
  realpath(path: string): string | null;
  removeFile(path: string): void;
  env: Record<string, string | undefined>;
}

const MAIN_SESSION = "main";
const TOOL_TAG = "@nvim_open_tool";
const PS_ANCESTRY_LIMIT = 64;

function shquote(value: string): string {
  return "'" + value.replace(/'/g, "'\\''") + "'";
}

interface PaneInfo {
  pane: string;
  session: string;
  window: string;
}

interface LiveNvim extends PaneInfo {
  sock: string;
  mtime: number;
}

export class NvimOpen {
  private readonly file: string;
  private live: LiveNvim[] = [];

  constructor(
    private readonly sys: Sys,
    file: string,
  ) {
    this.file = this.absPath(file);
  }

  run(): void {
    this.collectLiveNvim();
    const workspaceDir = this.workspaceDirForFile();
    if (workspaceDir && this.sys.realpath(workspaceDir)) {
      this.routeWorkspace(workspaceDir);
    } else {
      this.routeMain();
    }
  }

  private absPath(file: string): string {
    const dir = this.sys.realpath(dirname(file)) ?? dirname(file);
    return `${dir}/${basename(file)}`;
  }

  private tmux(...args: string[]): ExecResult {
    return this.sys.exec(["tmux", ...args]);
  }

  private tmuxLines(...args: string[]): string[] {
    return this.tmux(...args)
      .stdout.split("\n")
      .filter((line) => line.length > 0);
  }

  /** Find the tmux pane running an nvim server by matching its pid against each
   * pane's process tree, so it stays correct even if the window/pane was moved. */
  private paneForSocket(sock: string): PaneInfo | null {
    const pidResult = this.sys.exec(["nvim", "--server", sock, "--remote-expr", "getpid()"]);
    if (pidResult.code !== 0) return null;
    const pid = pidResult.stdout.trim();
    if (!/^\d+$/.test(pid)) return null;

    const ancestry = new Set<string>([pid]);
    let parent = pid;
    for (let i = 0; i < PS_ANCESTRY_LIMIT; i++) {
      parent = this.sys.exec(["ps", "-o", "ppid=", "-p", parent]).stdout.trim();
      if (!parent || parent === "0" || parent === "1") break;
      ancestry.add(parent);
    }

    for (const line of this.tmuxLines(
      "list-panes",
      "-a",
      "-F",
      "#{pane_pid}|#{pane_id}|#{session_name}|#{window_id}",
    )) {
      const [ppid, pane, session, window] = line.split("|");
      if (ppid && ancestry.has(ppid)) return { pane, session, window };
    }
    return null;
  }

  private collectLiveNvim(): void {
    for (const sock of this.sys.listSockets()) {
      if (this.sys.exec(["nvim", "--server", sock, "--remote-expr", "1"]).code !== 0) {
        this.sys.removeFile(sock);
        continue;
      }
      const info = this.paneForSocket(sock);
      if (!info) continue;
      this.live.push({ ...info, sock, mtime: this.sys.statMtime(sock) });
    }
  }

  /** Newest live nvim in a session; with requireTag, only windows this tool created qualify. */
  private pickSocketInSession(session: string, requireTag: boolean): LiveNvim | null {
    let best: LiveNvim | null = null;
    for (const nvim of this.live) {
      if (nvim.session !== session) continue;
      if (requireTag && this.windowTag(nvim.window) !== "1") continue;
      if (!best || nvim.mtime > best.mtime) best = nvim;
    }
    return best;
  }

  private windowTag(window: string): string {
    return this.tmux("show-options", "-wqv", "-t", window, TOOL_TAG).stdout.trim();
  }

  private sessionForPath(target: string): string | null {
    const real = this.sys.realpath(target) ?? target;
    for (const line of this.tmuxLines("list-sessions", "-F", "#{session_name}|#{session_path}")) {
      const [name, path] = line.split("|");
      if (!name || !path) continue;
      if (path === target || path === real || this.sys.realpath(path) === real) return name;
    }
    return null;
  }

  private uniqueSessionName(base: string): string {
    let candidate = base;
    for (let n = 2; this.tmux("has-session", "-t", `=${candidate}`).code === 0; n++) {
      candidate = `${base}-${n}`;
    }
    return candidate;
  }

  private focus(session: string, window: string, pane: string): void {
    this.tmux("switch-client", "-t", `=${session}`);
    if (window) this.tmux("select-window", "-t", window);
    if (pane) this.tmux("select-pane", "-t", pane);
    this.sys.exec(["osascript", "-e", 'tell application "Ghostty" to activate']);
  }

  private editorCommand(): string {
    const shell = this.sys.env.SHELL || "/bin/zsh";
    return `nvim -- ${shquote(this.file)}; exec ${shell}`;
  }

  private tagWindow(window: string): void {
    if (window) this.tmux("set-option", "-w", "-t", window, TOOL_TAG, "1");
  }

  private firstPane(window: string): string {
    return window ? (this.tmuxLines("list-panes", "-t", window, "-F", "#{pane_id}")[0] ?? "") : "";
  }

  private openInExisting(nvim: LiveNvim): void {
    this.sys.exec(["nvim", "--server", nvim.sock, "--remote", this.file]);
    this.focus(nvim.session, nvim.window, nvim.pane);
  }

  private newEditorWindow(session: string, dir: string): void {
    const window = this.tmux(
      "new-window",
      "-P",
      "-F",
      "#{window_id}",
      "-t",
      `=${session}:`,
      "-c",
      dir,
      this.editorCommand(),
    ).stdout.trim();
    this.tagWindow(window);
    this.focus(session, window, this.firstPane(window));
  }

  private newSessionWithEditor(session: string, dir: string): void {
    this.tmux("new-session", "-d", "-s", session, "-c", dir, this.editorCommand());
    const window = this.tmuxLines("list-windows", "-t", `=${session}`, "-F", "#{window_id}")[0] ?? "";
    this.tagWindow(window);
    this.focus(session, window, this.firstPane(window));
  }

  private routeWorkspace(workspaceDir: string): void {
    const session = this.sessionForPath(workspaceDir);
    if (!session) {
      this.newSessionWithEditor(this.uniqueSessionName(basename(workspaceDir)), workspaceDir);
      return;
    }
    const reuse = this.pickSocketInSession(session, false);
    if (reuse) this.openInExisting(reuse);
    else this.newEditorWindow(session, workspaceDir);
  }

  private routeMain(): void {
    if (this.tmux("has-session", "-t", `=${MAIN_SESSION}`).code !== 0) {
      this.tmux("new-session", "-d", "-s", MAIN_SESSION);
    }
    const reuse = this.pickSocketInSession(MAIN_SESSION, true);
    if (reuse) this.openInExisting(reuse);
    else this.newEditorWindow(MAIN_SESSION, this.gitRootOf(this.file));
  }

  private gitRootOf(file: string): string {
    const result = this.sys.exec(["git", "-C", dirname(file), "rev-parse", "--show-toplevel"]);
    return result.code === 0 && result.stdout.trim() ? result.stdout.trim() : dirname(file);
  }

  private workspaceDirForFile(): string | null {
    const root = this.sys.env.JJF_WORKSPACE_ROOT || `${this.sys.env.HOME}/workspaces/jj`;
    const rootReal = this.sys.realpath(root);
    if (!rootReal) return null;

    const fileDir = this.sys.realpath(dirname(this.file));
    if (!fileDir || !fileDir.startsWith(`${rootReal}/`)) return null;

    const segment = fileDir.slice(rootReal.length + 1).split("/")[0];
    if (!segment) return null;
    return `${rootReal}/${segment}`;
  }
}

function realSys(): Sys {
  return {
    exec(argv) {
      const proc = Bun.spawnSync(argv, { stdout: "pipe", stderr: "pipe" });
      return { code: proc.exitCode ?? 0, stdout: proc.stdout?.toString() ?? "" };
    },
    listSockets() {
      let names: string[];
      try {
        names = readdirSync("/tmp");
      } catch {
        return [];
      }
      const sockets: string[] = [];
      for (const name of names) {
        if (!name.startsWith("nvim-") || !name.endsWith(".sock")) continue;
        const path = `/tmp/${name}`;
        try {
          if (statSync(path).isSocket()) sockets.push(path);
        } catch {
          // vanished between readdir and stat; ignore
        }
      }
      return sockets;
    },
    statMtime(path) {
      try {
        return statSync(path).mtimeMs;
      } catch {
        return 0;
      }
    },
    realpath(path) {
      try {
        return realpathSync(path);
      } catch {
        return null;
      }
    },
    removeFile(path) {
      try {
        rmSync(path, { force: true });
      } catch {
        // best effort
      }
    },
    env: process.env,
  };
}

if (import.meta.main) {
  const file = process.argv[2];
  if (!file) {
    console.error("Usage: nvim-open <file>");
    process.exit(1);
  }
  new NvimOpen(realSys(), file).run();
}
