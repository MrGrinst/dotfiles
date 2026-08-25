import { test, expect } from "bun:test";
import { NvimOpen, type Sys, type ExecResult } from "./nvim-open.ts";

interface Pane {
  panePid: string;
  pane: string;
  session: string;
  window: string;
}

type Override = (argv: string[]) => ExecResult | null;

/** In-memory stand-in for tmux/nvim/ps/git so routing decisions can be asserted. */
class FakeSys implements Sys {
  calls: string[][] = [];
  removed: string[] = [];
  sockets: string[] = [];
  mtimes: Record<string, number> = {};
  realpaths: Record<string, string> = {};
  env: Record<string, string | undefined> = { HOME: "/home/kyle", SHELL: "/bin/zsh" };

  sessions = new Map<string, string>(); // name -> path
  panes: Pane[] = [];
  tagged = new Set<string>();
  private overrides: Override[] = [];
  private windowSeq = 0;

  exec(argv: string[]): ExecResult {
    this.calls.push(argv);
    for (const override of this.overrides) {
      const result = override(argv);
      if (result) return result;
    }
    if (argv[0] === "tmux") return this.tmux(argv.slice(1));
    return { code: 0, stdout: "" };
  }

  listSockets() {
    return this.sockets;
  }
  statMtime(path: string) {
    return this.mtimes[path] ?? 0;
  }
  realpath(path: string) {
    return this.realpaths[path] ?? null;
  }
  removeFile(path: string) {
    this.removed.push(path);
  }

  on(override: Override) {
    this.overrides.push(override);
  }
  ran(pred: (argv: string[]) => boolean) {
    return this.calls.some(pred);
  }

  private valueAfter(argv: string[], flag: string): string {
    const i = argv.indexOf(flag);
    return i >= 0 ? (argv[i + 1] ?? "") : "";
  }

  private tmux(a: string[]): ExecResult {
    const target = () => this.valueAfter(a, "-t").replace(/^=/, "").replace(/:$/, "");
    switch (a[0]) {
      case "has-session":
        return { code: this.sessions.has(target()) ? 0 : 1, stdout: "" };
      case "list-sessions":
        return {
          code: 0,
          stdout: [...this.sessions].map(([n, p]) => `${n}|${p}`).join("\n"),
        };
      case "list-panes": {
        if (a.includes("-a")) {
          return {
            code: 0,
            stdout: this.panes
              .map((p) => `${p.panePid}|${p.pane}|${p.session}|${p.window}`)
              .join("\n"),
          };
        }
        const win = this.valueAfter(a, "-t");
        return {
          code: 0,
          stdout: this.panes
            .filter((p) => p.window === win)
            .map((p) => p.pane)
            .join("\n"),
        };
      }
      case "list-windows": {
        const session = target();
        const windows = [...new Set(this.panes.filter((p) => p.session === session).map((p) => p.window))];
        return { code: 0, stdout: windows.join("\n") };
      }
      case "show-options":
        return { code: 0, stdout: this.tagged.has(this.valueAfter(a, "-t")) ? "1" : "" };
      case "new-window": {
        const session = target();
        const window = `@w${++this.windowSeq}`;
        this.panes.push({ panePid: "0", pane: `%${this.windowSeq}`, session, window });
        return { code: 0, stdout: window };
      }
      case "new-session": {
        const name = this.valueAfter(a, "-s");
        const path = this.valueAfter(a, "-c");
        this.sessions.set(name, path);
        const window = `@w${++this.windowSeq}`;
        this.panes.push({ panePid: "0", pane: `%${this.windowSeq}`, session: name, window });
        return { code: 0, stdout: "" };
      }
      default:
        return { code: 0, stdout: "" };
    }
  }
}

function addLiveNvim(
  sys: FakeSys,
  opts: {
    sock: string;
    chain: string[]; // [nvimPid, ...ancestors, panePid]
    pane: string;
    session: string;
    window: string;
    mtime?: number;
    tagged?: boolean;
  },
) {
  const { sock, chain } = opts;
  sys.sockets.push(sock);
  sys.mtimes[sock] = opts.mtime ?? 1;
  sys.panes.push({
    panePid: chain[chain.length - 1],
    pane: opts.pane,
    session: opts.session,
    window: opts.window,
  });
  if (opts.tagged) sys.tagged.add(opts.window);

  sys.on((argv) => {
    if (argv[0] !== "nvim" || argv[2] !== sock) return null;
    if (argv[3] === "--remote-expr" && argv[4] === "1") return { code: 0, stdout: "" };
    if (argv[3] === "--remote-expr" && argv[4] === "getpid()") return { code: 0, stdout: chain[0] };
    return null;
  });
  sys.on((argv) => {
    if (argv[0] !== "ps") return null;
    const pid = argv[argv.length - 1];
    const idx = chain.indexOf(pid);
    if (idx === -1) return null;
    return { code: 0, stdout: idx < chain.length - 1 ? chain[idx + 1] : "1" };
  });
}

function baseSys(): FakeSys {
  const sys = new FakeSys();
  sys.realpaths["/home/kyle/workspaces/jj"] = "/home/kyle/workspaces/jj";
  return sys;
}

const WS_DIR = "/home/kyle/workspaces/jj/dotfiles--foo";
const WS_FILE = `${WS_DIR}/src/x.ts`;
const MAIN_FILE = "/home/kyle/proj/a.ts";

function withWorkspacePaths(sys: FakeSys) {
  sys.realpaths[`${WS_DIR}/src`] = `${WS_DIR}/src`;
  sys.realpaths[WS_DIR] = WS_DIR;
}

function withMainPaths(sys: FakeSys) {
  sys.realpaths["/home/kyle/proj"] = "/home/kyle/proj";
  sys.on((argv) =>
    argv[0] === "git" && argv.includes("rev-parse") ? { code: 0, stdout: "/home/kyle/proj\n" } : null,
  );
}

const isRemoteOpen = (file: string) => (a: string[]) =>
  a[0] === "nvim" && a[3] === "--remote" && a[4] === file;
const isNewWindow = (a: string[]) => a[0] === "tmux" && a[1] === "new-window";
const isNewSession = (a: string[]) => a[0] === "tmux" && a[1] === "new-session";

test("non-workspace file with no editor opens a new tagged window in main", () => {
  const sys = baseSys();
  withMainPaths(sys);
  new NvimOpen(sys, MAIN_FILE).run();

  const win = sys.calls.find(isNewWindow)!;
  expect(win).toBeDefined();
  expect(win).toContain("=main:");
  expect(win).toContain("/home/kyle/proj"); // cwd = git root
  expect(win.join(" ")).toContain(MAIN_FILE);
  expect(sys.ran((a) => a[0] === "tmux" && a[1] === "set-option" && a.includes("@nvim_open_tool"))).toBe(true);
  expect(sys.ran(isRemoteOpen(MAIN_FILE))).toBe(false);
});

test("non-workspace file reuses the tool's tagged window in main", () => {
  const sys = baseSys();
  withMainPaths(sys);
  addLiveNvim(sys, {
    sock: "/tmp/nvim-1.sock",
    chain: ["1000", "900"],
    pane: "%1",
    session: "main",
    window: "@w1",
    tagged: true,
  });
  new NvimOpen(sys, MAIN_FILE).run();

  expect(sys.ran(isRemoteOpen(MAIN_FILE))).toBe(true);
  expect(sys.ran(isNewWindow)).toBe(false);
  expect(sys.ran((a) => a[0] === "tmux" && a[1] === "switch-client" && a.includes("=main"))).toBe(true);
});

test("non-workspace file ignores an untagged nvim in main and opens a new window", () => {
  const sys = baseSys();
  withMainPaths(sys);
  addLiveNvim(sys, {
    sock: "/tmp/nvim-1.sock",
    chain: ["1000", "900"],
    pane: "%1",
    session: "main",
    window: "@w1",
    tagged: false,
  });
  new NvimOpen(sys, MAIN_FILE).run();

  expect(sys.ran(isRemoteOpen(MAIN_FILE))).toBe(false);
  expect(sys.ran(isNewWindow)).toBe(true);
});

test("workspace file reuses nvim in the matching session (pane found via process tree)", () => {
  const sys = baseSys();
  withWorkspacePaths(sys);
  sys.sessions.set("dotfiles--foo", WS_DIR);
  addLiveNvim(sys, {
    sock: "/tmp/nvim-2.sock",
    chain: ["1000", "900", "800"], // nvim -> shell -> pane_pid, grandchild depth
    pane: "%5",
    session: "dotfiles--foo",
    window: "@w9",
  });
  new NvimOpen(sys, WS_FILE).run();

  expect(sys.ran(isRemoteOpen(WS_FILE))).toBe(true);
  expect(sys.ran(isNewWindow)).toBe(false);
  expect(sys.ran((a) => a[0] === "tmux" && a[1] === "switch-client" && a.includes("=dotfiles--foo"))).toBe(true);
});

test("workspace file with a session but no nvim opens a new window in that session", () => {
  const sys = baseSys();
  withWorkspacePaths(sys);
  sys.sessions.set("dotfiles--foo", WS_DIR);
  new NvimOpen(sys, WS_FILE).run();

  const win = sys.calls.find(isNewWindow)!;
  expect(win).toBeDefined();
  expect(win).toContain("=dotfiles--foo:");
  expect(win).toContain(WS_DIR);
  expect(sys.ran(isNewSession)).toBe(false);
});

test("workspace file with no session creates one named after the workspace dir", () => {
  const sys = baseSys();
  withWorkspacePaths(sys);
  new NvimOpen(sys, WS_FILE).run();

  const sess = sys.calls.find(isNewSession)!;
  expect(sess).toBeDefined();
  expect(sess).toContain("dotfiles--foo");
  expect(sess).toContain(WS_DIR);
  expect(sess.join(" ")).toContain(WS_FILE);
});

test("dead sockets are pruned and do not route anywhere", () => {
  const sys = baseSys();
  withMainPaths(sys);
  sys.sockets.push("/tmp/nvim-dead.sock");
  sys.on((argv) =>
    argv[0] === "nvim" && argv[2] === "/tmp/nvim-dead.sock" ? { code: 1, stdout: "" } : null,
  );
  new NvimOpen(sys, MAIN_FILE).run();

  expect(sys.removed).toContain("/tmp/nvim-dead.sock");
  expect(sys.ran(isNewWindow)).toBe(true);
});

test("newest nvim wins when several live in the same session", () => {
  const sys = baseSys();
  withMainPaths(sys);
  addLiveNvim(sys, {
    sock: "/tmp/nvim-old.sock",
    chain: ["1000", "900"],
    pane: "%1",
    session: "main",
    window: "@w1",
    tagged: true,
    mtime: 100,
  });
  addLiveNvim(sys, {
    sock: "/tmp/nvim-new.sock",
    chain: ["2000", "1900"],
    pane: "%2",
    session: "main",
    window: "@w2",
    tagged: true,
    mtime: 200,
  });
  new NvimOpen(sys, MAIN_FILE).run();

  expect(sys.ran((a) => a[0] === "nvim" && a[2] === "/tmp/nvim-new.sock" && a[3] === "--remote")).toBe(true);
  expect(sys.ran((a) => a[0] === "nvim" && a[2] === "/tmp/nvim-old.sock" && a[3] === "--remote")).toBe(false);
});
