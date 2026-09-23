#!/usr/bin/env bun
import { spawn, spawnSync } from "node:child_process";
import {
  existsSync,
  mkdirSync,
  readdirSync,
  readFileSync,
  realpathSync,
  renameSync,
  rmSync,
  statSync,
  writeFileSync,
} from "node:fs";
import { homedir } from "node:os";
import { basename, join } from "node:path";

const HOME = homedir();
const WORKSPACE_ROOT = process.env.JJF_WORKSPACE_ROOT ?? join(HOME, "workspaces/jj");
const REGISTRY_PATH = join(WORKSPACE_ROOT, ".jjf-registry.tsv");
const CLAUDE_DIR = join(HOME, ".claude");
const CLAUDE_HISTORY_PATH = join(CLAUDE_DIR, "history.jsonl");
const JJ_REPO_CONFIG_DIR = join(HOME, ".config/jj/repos");
const STATE_DIR = join(HOME, ".local/state/jjf-prune");
const KEPT_PATH = join(STATE_DIR, "kept.json");
const SUMMARY_CACHE_DIR = join(STATE_DIR, "summaries");
const BASE_BOOKMARKS = new Set(["dev", "main", "master"]);
const SCAN_CONCURRENCY = 8;
const SUMMARY_PREFETCH = 3;
const ORIGIN = 'remote_bookmarks(remote=exact:"origin")';
const PASSIVE_OP_PATTERN = '"^(snapshot working copy|import git head|import git refs|fetch from git remote)"';

type PrState = "OPEN" | "MERGED" | "CLOSED";
type Status = "merged" | "open" | "closed" | "no-pr" | "unknown";

interface Pr {
  number: number;
  title: string;
  state: PrState;
  url: string;
  mergedAt: string | null;
  headRefName: string;
  headRefOid: string;
  author: { login: string };
  body: string;
}

interface Commit {
  id: string;
  empty: boolean;
  subject: string;
}

interface Prompt {
  display: string;
  timestamp: number;
  sessionId: string;
}

interface Workspace {
  name: string;
  path: string;
  repo: string;
  ghRepo: string | null;
  vcs: "jj" | "git";
  bookmarks: string[];
  commits: Commit[];
  unpushed: Commit[];
  unmerged: Commit[];
  prs: Pr[];
  prompts: Prompt[];
  lastTouched: number;
  status: Status;
  safeToDelete: boolean;
}

interface RunResult {
  code: number;
  stdout: string;
  stderr: string;
}

const run = (cmd: string, args: string[], opts: { cwd?: string; input?: string } = {}) =>
  new Promise<RunResult>((resolve) => {
    const child = spawn(cmd, args, { cwd: opts.cwd, stdio: ["pipe", "pipe", "pipe"] });
    let stdout = "";
    let stderr = "";
    child.stdout.on("data", (d) => (stdout += d));
    child.stderr.on("data", (d) => (stderr += d));
    child.on("error", (err) => resolve({ code: -1, stdout, stderr: String(err) }));
    child.on("close", (code) => resolve({ code: code ?? -1, stdout, stderr }));
    child.stdin.end(opts.input ?? "");
  });

const pool = async <T, R>(items: T[], limit: number, fn: (item: T) => Promise<R>) => {
  const results: R[] = new Array(items.length);
  let next = 0;
  const worker = async () => {
    while (next < items.length) {
      const i = next++;
      results[i] = await fn(items[i]);
    }
  };
  await Promise.all(Array.from({ length: Math.min(limit, items.length) }, worker));
  return results;
};

const color = (code: number) => (s: string) => (process.stdout.isTTY ? `\x1b[${code}m${s}\x1b[0m` : s);
const bold = color(1);
const dim = color(2);
const red = color(31);
const green = color(32);
const yellow = color(33);
const blue = color(34);
const magenta = color(35);

const readJson = <T>(path: string, fallback: T): T => {
  try {
    return JSON.parse(readFileSync(path, "utf8"));
  } catch {
    return fallback;
  }
};

const writeFileAtomic = (path: string, contents: string) => {
  const tmp = `${path}.${process.pid}.tmp`;
  writeFileSync(tmp, contents);
  renameSync(tmp, path);
};

const formatDate = (ms: number) => (ms ? new Date(ms).toISOString().slice(0, 10) : "?");

const formatAge = (ms: number) => {
  if (!ms) return "?";
  const days = Math.floor((Date.now() - ms) / 86_400_000);
  if (days < 1) return "today";
  if (days < 60) return `${days}d ago`;
  return `${Math.floor(days / 30)}mo ago`;
};

const repoNameFromDir = (name: string) => name.split("--")[0];

const ghRepoFromRemote = (url: string) => url.trim().match(/github\.com[:/](.+?)(?:\.git)?$/)?.[1] ?? null;

const claudeProjectDirName = (path: string) => path.replace(/[^a-zA-Z0-9]/g, "-");

const isInside = (path: string, root: string) => path === root || path.startsWith(`${root}/`);

const readRegistry = () =>
  existsSync(REGISTRY_PATH)
    ? readFileSync(REGISTRY_PATH, "utf8")
        .split("\n")
        .filter(Boolean)
        .map((line) => {
          const [repo, alias, path] = line.split("\t");
          return { repo, alias, path };
        })
    : [];

const readClaudeHistory = (): (Prompt & { project: string })[] =>
  existsSync(CLAUDE_HISTORY_PATH)
    ? readFileSync(CLAUDE_HISTORY_PATH, "utf8")
        .split("\n")
        .flatMap((line) => {
          try {
            const entry = JSON.parse(line);
            return entry.project ? [entry] : [];
          } catch {
            return [];
          }
        })
    : [];

const listWorkspaceDirs = () =>
  readdirSync(WORKSPACE_ROOT, { withFileTypes: true })
    .filter((d) => d.isDirectory() && d.name.includes("--"))
    .map((d) => join(WORKSPACE_ROOT, d.name));

const jj = (cwd: string, ...args: string[]) => run("jj", ["--no-pager", "--color=never", ...args], { cwd });

const COMMIT_TEMPLATE = [
  "commit_id.short(12)",
  'if(empty, "1", "0")',
  'local_bookmarks.map(|b| b.name()).join(",")',
  'remote_bookmarks.filter(|b| b.remote() == "origin").map(|b| b.name()).join(",")',
  "description.first_line()",
].join(' ++ "\\t" ++ ') + ' ++ "\\n"';

const parseCommitLines = (stdout: string) =>
  stdout
    .split("\n")
    .filter(Boolean)
    .map((line) => {
      const [id, empty, local, remote, subject] = line.split("\t");
      return {
        commit: { id, empty: empty === "1", subject: subject ?? "" },
        bookmarks: [...(local ? local.split(",") : []), ...(remote ? remote.split(",") : [])],
      };
    });

const scanJj = async (path: string) => {
  const opTimes = await jj(
    path, "--ignore-working-copy", "op", "log", "-n200", "--no-graph", "-T",
    `if(self.description().first_line().match(regex:${PASSIVE_OP_PATTERN}), "", self.time().end().format("%s") ++ "\\n")`,
  );
  await jj(path, "util", "snapshot");
  const [range, unpushed] = await Promise.all([
    jj(path, "--ignore-working-copy", "log", "--no-graph", "-r", "trunk()..@", "-T", COMMIT_TEMPLATE),
    jj(path, "--ignore-working-copy", "log", "--no-graph", "-r", `(trunk()..@) ~ ::${ORIGIN} ~ empty()`, "-T", COMMIT_TEMPLATE),
  ]);
  const rows = parseCommitLines(range.stdout);
  return {
    lastOp: Number(opTimes.stdout.split("\n")[0]) * 1000 || 0,
    commits: rows.map((r) => r.commit),
    bookmarks: rows.flatMap((r) => r.bookmarks),
    unpushed: parseCommitLines(unpushed.stdout).map((r) => r.commit),
  };
};

const git = (cwd: string, ...args: string[]) => run("git", args, { cwd });

const scanGit = async (path: string) => {
  const [branch, log, unpushed, status, reflog, lastCommit] = await Promise.all([
    git(path, "rev-parse", "--abbrev-ref", "HEAD"),
    git(path, "log", "--format=%h%x09%s", "origin/HEAD..HEAD"),
    git(path, "log", "--format=%h%x09%s", "HEAD", "--not", "--remotes"),
    git(path, "status", "--porcelain"),
    git(path, "rev-parse", "--path-format=absolute", "--git-path", "logs/HEAD"),
    git(path, "log", "-1", "--format=%ct", "HEAD"),
  ]);
  const toCommits = (stdout: string) =>
    stdout
      .split("\n")
      .filter(Boolean)
      .map((line) => {
        const [id, subject] = line.split("\t");
        return { id, empty: false, subject };
      });
  const uncommitted = status.stdout.trim() ? [{ id: "worktree", empty: false, subject: "(uncommitted changes)" }] : [];
  const reflogPath = reflog.stdout.trim();
  return {
    lastOp: Math.max(existsSync(reflogPath) ? statSync(reflogPath).mtimeMs : 0, Number(lastCommit.stdout.trim()) * 1000 || 0),
    commits: toCommits(log.stdout),
    bookmarks: branch.stdout.trim() === "HEAD" ? [] : [branch.stdout.trim()],
    unpushed: [...toCommits(unpushed.stdout), ...uncommitted],
  };
};

const prCache = new Map<string, Promise<Pr[] | null>>();

const fetchPrs = (ghRepo: string, branch: string) => {
  const key = `${ghRepo}:${branch}`;
  if (!prCache.has(key)) {
    prCache.set(
      key,
      run("gh", [
        "pr", "list", "--repo", ghRepo, "--head", branch, "--state", "all", "--limit", "10",
        "--json", "number,title,state,url,mergedAt,headRefName,headRefOid,author,body",
      ]).then((r) => (r.code === 0 ? (JSON.parse(r.stdout) as Pr[]) : null)),
    );
  }
  return prCache.get(key)!;
};

const statusFromPrs = (prs: Pr[] | null): Status => {
  if (prs === null) return "unknown";
  if (prs.length === 0) return "no-pr";
  if (prs.some((pr) => pr.state === "OPEN")) return "open";
  if (prs.some((pr) => pr.state === "MERGED")) return "merged";
  return "closed";
};

const unmergedCommits = async (
  path: string,
  vcs: Workspace["vcs"],
  prs: Pr[],
  commits: Commit[],
): Promise<Commit[] | null> => {
  const heads = prs.filter((p) => p.state === "MERGED").map((p) => p.headRefOid);
  if (!heads.length) return null;
  if (!commits.some((c) => !c.empty)) return [];
  if (vcs === "git") {
    const covered = await Promise.all(heads.map((oid) => git(path, "merge-base", "--is-ancestor", "HEAD", oid)));
    return covered.some((r) => r.code === 0) ? [] : null;
  }
  const revset = `(trunk()..@) ~ ::(${heads.join(" | ")}) ~ empty()`;
  const result = await jj(path, "--ignore-working-copy", "log", "--no-graph", "-r", revset, "-T", COMMIT_TEMPLATE);
  if (result.code === 0 && !result.stdout.trim()) return [];
  // Commits rebased or re-described after the final push are still merged if @ has the exact merged tree.
  for (const oid of heads) {
    const diff = await jj(path, "--ignore-working-copy", "diff", "--from", oid, "--to", "@", "--summary");
    if (diff.code === 0 && !diff.stdout.trim()) return [];
  }
  return result.code === 0 ? parseCommitLines(result.stdout).map((r) => r.commit) : null;
};

const scanWorkspace = async (
  path: string,
  registry: ReturnType<typeof readRegistry>,
  history: ReturnType<typeof readClaudeHistory>,
): Promise<Workspace> => {
  const name = basename(path);
  const vcs = existsSync(join(path, ".jj")) ? "jj" : "git";
  let scan = vcs === "jj" ? await scanJj(path) : await scanGit(path);
  const remote =
    vcs === "jj"
      ? (await jj(path, "--ignore-working-copy", "git", "remote", "list")).stdout.match(/^origin\s+(\S+)/m)?.[1] ?? ""
      : (await git(path, "remote", "get-url", "origin")).stdout;
  const ghRepo = ghRepoFromRemote(remote);

  const registered = registry.filter((r) => r.path === path).map((r) => r.alias);
  let bookmarks = [...new Set([...registered, ...scan.bookmarks])].filter((b) => !BASE_BOOKMARKS.has(b));
  if (bookmarks.length === 0) bookmarks = [name.slice(name.indexOf("--") + 2)];

  const lookups = ghRepo ? await Promise.all(bookmarks.map((b) => fetchPrs(ghRepo, b))) : [null];
  const status = statusFromPrs(lookups.includes(null) ? null : lookups.flat() as Pr[]);
  const prs = [...new Map(lookups.flatMap((l) => l ?? []).map((pr) => [pr.number, pr])).values()];

  let unmerged = status === "merged" ? await unmergedCommits(path, vcs, prs, scan.commits) : null;
  if (status === "merged" && unmerged?.length !== 0) {
    if (vcs === "jj") await jj(path, "--ignore-working-copy", "git", "fetch", "--remote", "origin");
    else await git(path, "fetch", "--quiet", "origin");
    scan = { ...(vcs === "jj" ? await scanJj(path) : await scanGit(path)), lastOp: scan.lastOp };
    unmerged = await unmergedCommits(path, vcs, prs, scan.commits);
  }
  const unpushed = unmerged?.length === 0 ? [] : scan.unpushed;

  const prompts = history
    .filter((h) => isInside(h.project, path))
    .map(({ display, timestamp, sessionId }) => ({ display, timestamp, sessionId }))
    .sort((a, b) => a.timestamp - b.timestamp);
  const lastPrompt = prompts.at(-1)?.timestamp ?? 0;

  return {
    name,
    path,
    repo: repoNameFromDir(name),
    ghRepo,
    vcs,
    bookmarks,
    commits: scan.commits,
    unpushed,
    prs,
    prompts,
    lastTouched: Math.max(scan.lastOp, lastPrompt),
    status,
    unmerged: unmerged ?? scan.commits.filter((c) => !c.empty),
    safeToDelete: status === "merged" && unmerged?.length === 0 && scan.unpushed.every((c) => c.id !== "worktree"),
  };
};

const scanAll = async (filter?: (path: string) => boolean) => {
  const registry = readRegistry();
  const history = readClaudeHistory();
  const dirs = listWorkspaceDirs().filter(filter ?? (() => true));
  let done = 0;
  const workspaces = await pool(dirs, SCAN_CONCURRENCY, async (path) => {
    const ws = await scanWorkspace(path, registry, history);
    if (process.stderr.isTTY) process.stderr.write(`\r${dim(`scanning ${++done}/${dirs.length}`)}\x1b[K`);
    return ws;
  });
  if (process.stderr.isTTY) process.stderr.write("\r\x1b[K");
  return workspaces.sort((a, b) => a.lastTouched - b.lastTouched);
};

const STATUS_LABEL: Record<Status, string> = {
  merged: green("merged"),
  open: blue("open"),
  closed: red("closed"),
  "no-pr": yellow("no-pr"),
  unknown: red("gh-error"),
};

const prLabel = (ws: Workspace) =>
  ws.prs.length ? ws.prs.map((pr) => `#${pr.number}`).join(",") : "—";

const printTable = (workspaces: Workspace[]) => {
  for (const ws of workspaces) {
    const flags = ws.unpushed.length ? yellow(` ▲${ws.unpushed.length} unpushed`) : "";
    console.log(
      `${formatDate(ws.lastTouched)}  ${STATUS_LABEL[ws.status].padEnd(15)} ${prLabel(ws).padEnd(12)} ${ws.name}${flags}`,
    );
  }
};

const removeClaudeHistory = (paths: string[]) => {
  const sessionIds = new Set<string>();
  const kept: string[] = [];
  if (existsSync(CLAUDE_HISTORY_PATH)) {
    for (const line of readFileSync(CLAUDE_HISTORY_PATH, "utf8").split("\n")) {
      if (!line) continue;
      let project: string | undefined;
      let sessionId: string | undefined;
      try {
        ({ project, sessionId } = JSON.parse(line));
      } catch {}
      if (project && paths.some((p) => isInside(project!, p))) {
        if (sessionId) sessionIds.add(sessionId);
      } else {
        kept.push(line);
      }
    }
    writeFileAtomic(CLAUDE_HISTORY_PATH, kept.length ? `${kept.join("\n")}\n` : "");
  }

  const projectsDir = join(CLAUDE_DIR, "projects");
  const projectDirs = new Set(paths.map(claudeProjectDirName));
  for (const dir of existsSync(projectsDir) ? readdirSync(projectsDir) : []) {
    if (projectDirs.has(dir)) {
      for (const f of readdirSync(join(projectsDir, dir))) {
        if (f.endsWith(".jsonl")) sessionIds.add(f.replace(/\.jsonl$/, ""));
      }
      rmSync(join(projectsDir, dir), { recursive: true, force: true });
    }
  }

  for (const id of sessionIds) {
    for (const sub of ["file-history", "session-env", "todos"]) {
      rmSync(join(CLAUDE_DIR, sub, id), { recursive: true, force: true });
    }
  }
};

const removeRegistryEntries = (paths: string[]) => {
  if (!existsSync(REGISTRY_PATH)) return;
  const lines = readFileSync(REGISTRY_PATH, "utf8")
    .split("\n")
    .filter((line) => line && !paths.includes(line.split("\t")[2]));
  writeFileAtomic(REGISTRY_PATH, lines.length ? `${lines.join("\n")}\n` : "");
};

const removeJjRepoConfigs = (paths: string[]) => {
  if (!existsSync(JJ_REPO_CONFIG_DIR)) return;
  const needles = paths.map((p) => `${p}/.jj/repo`);
  for (const id of readdirSync(JJ_REPO_CONFIG_DIR)) {
    const metadata = join(JJ_REPO_CONFIG_DIR, id, "metadata.binpb");
    if (!existsSync(metadata)) continue;
    const contents = readFileSync(metadata, "latin1");
    if (needles.some((n) => contents.includes(n))) rmSync(join(JJ_REPO_CONFIG_DIR, id), { recursive: true, force: true });
  }
};

const killTmuxSessions = async (paths: string[]) => {
  const sessions = await run("tmux", ["list-sessions", "-F", "#{session_name}\t#{session_path}\t#{session_attached}"]);
  if (sessions.code !== 0) return;
  for (const line of sessions.stdout.split("\n").filter(Boolean)) {
    const [name, sessionPath, attached] = line.split("\t");
    if (!paths.some((p) => isInside(sessionPath, p))) continue;
    if (attached !== "0") {
      console.log(yellow(`  leaving attached tmux session ${name}`));
      continue;
    }
    await run("tmux", ["kill-session", "-t", `=${name}`]);
  }
};

// jjf-rename leaves the pre-rename path as a symlink, and sessions started there still use it.
const symlinkAliases = (paths: string[]) =>
  readdirSync(WORKSPACE_ROOT, { withFileTypes: true })
    .filter((d) => d.isSymbolicLink())
    .map((d) => join(WORKSPACE_ROOT, d.name))
    .filter((link) => {
      try {
        return paths.includes(realpathSync(link));
      } catch {
        return false;
      }
    });

const deleteWorkspaces = async (workspaces: Workspace[]) => {
  const paths = workspaces.map((ws) => ws.path);
  const aliases = symlinkAliases(paths);
  await killTmuxSessions([...paths, ...aliases]);
  let done = 0;
  await pool(workspaces, 4, async (ws) => {
    const commonDir = ws.vcs === "git" ? (await git(ws.path, "rev-parse", "--path-format=absolute", "--git-common-dir")).stdout.trim() : "";
    await run("rm", ["-rf", ws.path]);
    if (commonDir && !isInside(commonDir, ws.path)) await run("git", ["--git-dir", commonDir, "worktree", "prune"]);
    await run("zoxide", ["remove", ws.path]);
    console.log(`${dim(`[${++done}/${workspaces.length}]`)} ${red("deleted")} ${ws.name}`);
  });
  for (const link of aliases) {
    rmSync(link, { force: true });
    await run("zoxide", ["remove", link]);
  }
  removeRegistryEntries(paths);
  removeJjRepoConfigs(paths);
  removeClaudeHistory([...paths, ...aliases]);
};

const confirm = async (question: string) => {
  process.stdout.write(`${question} [y/N] `);
  const answer = await new Promise<string>((resolve) => {
    process.stdin.once("data", (d) => resolve(String(d).trim().toLowerCase()));
    // Review mode leaves stdin explicitly paused, and a new listener doesn't resume a paused stream.
    process.stdin.resume();
  });
  process.stdin.pause();
  return answer === "y" || answer === "yes";
};

type KeptMap = Record<string, { keptAt: number; lastTouched: number }>;

const readKept = () => readJson<KeptMap>(KEPT_PATH, {});

const saveKept = (kept: KeptMap) => {
  mkdirSync(STATE_DIR, { recursive: true });
  writeFileAtomic(KEPT_PATH, JSON.stringify(kept, null, 2));
};

const summaryCachePath = (ws: Workspace) => join(SUMMARY_CACHE_DIR, `${ws.name}@${ws.lastTouched}.txt`);

const truncate = (s: string, n: number) => (s.length > n ? `${s.slice(0, n)}…` : s);

const PR_STATE_DESCRIPTION: Record<PrState, string> = {
  OPEN: "still open",
  MERGED: "merged",
  CLOSED: "closed WITHOUT merging",
};

const summaryPrompt = async (ws: Workspace) => {
  const diffStat =
    ws.vcs === "jj"
      ? (await jj(ws.path, "--ignore-working-copy", "diff", "--stat", "-r", "trunk()..@")).stdout
      : (await git(ws.path, "diff", "--stat", "origin/HEAD")).stdout;
  const prompts = ws.prompts.length > 8 ? [...ws.prompts.slice(0, 5), ...ws.prompts.slice(-3)] : ws.prompts;
  return [
    "You are helping a developer triage old workspaces (one branch checkout each) and decide which to delete.",
    "From the context below, write 2-4 plain sentences, no preamble or markdown: what the work was trying to do,",
    "how far it got, and whether it holds anything worth keeping (unshipped code, findings from an investigation or spike)",
    "or looks abandoned/superseded. If it's clearly just a checkout of someone else's branch for review, say so.",
    "",
    `Workspace: ${ws.name}`,
    `PRs: ${ws.prs.map((pr) => `#${pr.number} [${PR_STATE_DESCRIPTION[pr.state]}] ${pr.title} by ${pr.author.login}\n${truncate(pr.body ?? "", 1500)}`).join("\n\n") || "none"}`,
    `Commits (newest first):\n${ws.commits.map((c) => `- ${c.subject || "(no description)"}${c.empty ? " (empty)" : ""}`).join("\n") || "none"}`,
    `Local commits not pushed to GitHub: ${ws.unpushed.length}`,
    `Diff stat vs trunk:\n${truncate(diffStat, 3000) || "no changes"}`,
    `Developer's prompts to Claude in this workspace:\n${prompts.map((p) => `- ${truncate(p.display, 400)}`).join("\n") || "none"}`,
  ].join("\n");
};

const generateSummary = async (ws: Workspace, model: string) => {
  const cachePath = summaryCachePath(ws);
  if (existsSync(cachePath)) return readFileSync(cachePath, "utf8");
  mkdirSync(SUMMARY_CACHE_DIR, { recursive: true });
  const result = await run("claude", ["-p", "--model", model, "--no-session-persistence", "--tools", ""], {
    cwd: STATE_DIR,
    input: await summaryPrompt(ws),
  });
  const summary = result.code === 0 ? result.stdout.trim() : red(`summary failed: ${truncate(result.stderr.trim(), 200)}`);
  if (result.code === 0) writeFileSync(cachePath, summary);
  return summary;
};

const wrap = (text: string, width: number, indent = "  ") =>
  text
    .split("\n")
    .flatMap((para) => {
      const lines: string[] = [];
      let line = "";
      for (const word of para.split(/\s+/)) {
        if ((line + word).length > width - indent.length && line) {
          lines.push(line.trimEnd());
          line = "";
        }
        line += `${word} `;
      }
      lines.push(line.trimEnd());
      return lines;
    })
    .map((l) => indent + l)
    .join("\n");

const renderCard = (ws: Workspace, index: number, total: number, summary: string | null) => {
  const width = Math.min(process.stdout.columns || 100, 110);
  const out: string[] = [];
  out.push(dim(`${index + 1}/${total}`) + "  " + bold(ws.name));
  out.push(
    `  ${STATUS_LABEL[ws.status]}  ·  last touched ${formatDate(ws.lastTouched)} (${formatAge(ws.lastTouched)})` +
      (ws.unpushed.length ? `  ·  ${yellow(`▲${ws.unpushed.length} unpushed`)}` : ""),
  );
  for (const pr of ws.prs) {
    out.push(`  ${magenta(`#${pr.number}`)} [${pr.state.toLowerCase()}] ${pr.title} ${dim(`— ${pr.author.login}`)}`);
    out.push(`  ${dim(pr.url)}`);
  }
  if (!ws.prs.length) out.push(`  ${dim(`bookmarks: ${ws.bookmarks.join(", ")}`)}`);
  out.push("");
  out.push(bold("  Commits"));
  const commits = ws.commits.filter((c) => !c.empty || c.subject);
  if (!commits.length) out.push(dim("  (none beyond trunk)"));
  for (const c of commits.slice(0, 8)) {
    const pushed = ws.unpushed.some((u) => u.id === c.id) ? yellow(" ▲") : "";
    out.push(`  ${dim(c.id.slice(0, 8))} ${truncate(c.subject || "(no description)", width - 16)}${pushed}`);
  }
  if (commits.length > 8) out.push(dim(`  …${commits.length - 8} more`));
  if (ws.prompts.length) {
    out.push("");
    out.push(bold(`  Claude prompts (${ws.prompts.length})`));
    for (const p of ws.prompts.slice(0, 3)) out.push(dim(`  › ${truncate(p.display.replace(/\s+/g, " "), width - 6)}`));
  }
  out.push("");
  out.push(bold("  Summary"));
  out.push(summary ? wrap(summary, width) : dim("  thinking…"));
  out.push("");
  out.push(
    dim("  ") +
      `${red("[d]")} delete  ${green("[k]")} keep  ${dim("[s]")} skip  ${dim("[o]")} open PR  ${dim("[v]")} diff  ${dim("[p]")} prompts  ${dim("[u]")} undo  ${dim("[q]")} finish`,
  );
  process.stdout.write(`\x1b[2J\x1b[H${out.join("\n")}\n`);
};

const readKey = () =>
  new Promise<string>((resolve) => {
    process.stdin.setRawMode(true);
    process.stdin.resume();
    process.stdin.once("data", (d) => {
      process.stdin.setRawMode(false);
      process.stdin.pause();
      resolve(String(d));
    });
  });

const page = (text: string) => spawnSync("less", ["-R"], { input: text, stdio: ["pipe", "inherit", "inherit"] });

const showDiff = async (ws: Workspace) => {
  const diff =
    ws.vcs === "jj"
      ? await jj(ws.path, "--ignore-working-copy", "--color=always", "diff", "--git", "-r", "trunk()..@")
      : await git(ws.path, "diff", "--color=always", "origin/HEAD");
  page(diff.stdout || "no changes vs trunk\n");
};

const showPrompts = (ws: Workspace) =>
  page(
    ws.prompts.map((p) => `${dim(new Date(p.timestamp).toLocaleString())}\n${p.display}\n`).join("\n") ||
      "no Claude prompts recorded\n",
  );

const review = async (candidates: Workspace[], model: string) => {
  const summaries = new Map<string, Promise<string>>();
  const ensureSummary = (i: number) => {
    const ws = candidates[i];
    if (ws && !summaries.has(ws.name)) summaries.set(ws.name, generateSummary(ws, model));
  };
  const decisions: { ws: Workspace; action: "delete" | "keep" | "skip" }[] = [];
  const kept = readKept();

  let i = 0;
  while (i < candidates.length) {
    const ws = candidates[i];
    for (let j = i; j <= i + SUMMARY_PREFETCH; j++) ensureSummary(j);
    let summary: string | null = null;
    let waiting = true;
    summaries.get(ws.name)!.then((s) => {
      summary = s;
      if (waiting) renderCard(ws, i, candidates.length, summary);
    });
    renderCard(ws, i, candidates.length, summary);
    const key = await readKey();
    waiting = false;

    if (key === "d" || key === "\x1b[D") decisions.push({ ws, action: "delete" });
    else if (key === "k" || key === "\x1b[C") {
      decisions.push({ ws, action: "keep" });
      kept[ws.name] = { keptAt: Date.now(), lastTouched: ws.lastTouched };
      saveKept(kept);
    } else if (key === "s" || key === " ") decisions.push({ ws, action: "skip" });
    else if (key === "o") {
      if (ws.prs[0]) await run("open", [ws.prs[0].url]);
      continue;
    } else if (key === "v") {
      await showDiff(ws);
      continue;
    } else if (key === "p") {
      showPrompts(ws);
      continue;
    } else if (key === "u") {
      const last = decisions.pop();
      if (last) {
        if (last.action === "keep") {
          delete kept[last.ws.name];
          saveKept(kept);
        }
        i--;
      }
      continue;
    } else if (key === "q" || key === "\x03") break;
    else continue;
    i++;
  }

  process.stdout.write("\x1b[2J\x1b[H");
  return decisions.filter((d) => d.action === "delete").map((d) => d.ws);
};

const parseArgs = (argv: string[]) => {
  const flags = new Set(argv.filter((a) => a.startsWith("--") && !a.includes("=")));
  const opt = (name: string) => argv.find((a) => a.startsWith(`--${name}=`))?.split("=")[1];
  const positional = argv.filter((a) => !a.startsWith("--"));
  return { command: positional[0] ?? "list", rest: positional.slice(1), flags, opt };
};

const USAGE = `Usage:
  jjf-prune [list] [--json]         Show every workspace under ${WORKSPACE_ROOT} with PR/merge status
  jjf-prune clean [--yes]           Delete workspaces whose PRs merged and that have nothing unpushed
  jjf-prune review [--all] [--model=haiku]
                                    Swipe through the rest one at a time with a Claude summary;
                                    kept ones are skipped next time unless touched since (or --all)
  jjf-prune summary <name>          Print the Claude summary review mode shows for one workspace
  jjf-prune rm <name>...            Delete specific workspaces

Deleting removes the workspace dir, its tmux session, .jjf-registry.tsv entry, jj repo config,
zoxide entry, and its Claude history (project dir, history.jsonl prompts, per-session state).`;

const main = async () => {
  const { command, rest, flags, opt } = parseArgs(process.argv.slice(2));

  if (command === "help" || flags.has("--help")) {
    console.log(USAGE);
    return;
  }

  if (command === "list") {
    const workspaces = await scanAll();
    if (flags.has("--json")) {
      console.log(JSON.stringify(workspaces.map(({ prompts, ...ws }) => ({ ...ws, promptCount: prompts.length, prs: ws.prs.map(({ body, ...pr }) => pr) })), null, 2));
      return;
    }
    const safe = workspaces.filter((ws) => ws.safeToDelete);
    const rest = workspaces.filter((ws) => !ws.safeToDelete);
    console.log(bold(`Merged, nothing unpushed (${safe.length}) — \`jjf-prune clean\` deletes these`));
    printTable(safe);
    console.log(`\n${bold(`Needs a decision (${rest.length}) — \`jjf-prune review\``)}`);
    printTable(rest);
    return;
  }

  if (command === "clean") {
    const safe = (await scanAll()).filter((ws) => ws.safeToDelete);
    if (!safe.length) return console.log("Nothing merged to clean up.");
    printTable(safe);
    if (flags.has("--yes") || (await confirm(`\nDelete these ${safe.length} workspaces and their Claude history?`))) {
      await deleteWorkspaces(safe);
    }
    return;
  }

  if (command === "review") {
    const kept = readKept();
    const candidates = (await scanAll()).filter(
      (ws) => !ws.safeToDelete && (flags.has("--all") || !kept[ws.name] || kept[ws.name].lastTouched < ws.lastTouched),
    );
    if (!candidates.length) return console.log("Nothing left to review.");
    const toDelete = await review(candidates, opt("model") ?? "haiku");
    if (!toDelete.length) return console.log("No workspaces marked for deletion.");
    printTable(toDelete);
    if (await confirm(`\nDelete these ${toDelete.length} workspaces and their Claude history?`)) await deleteWorkspaces(toDelete);
    return;
  }

  if (command === "summary") {
    const path = join(WORKSPACE_ROOT, basename(rest[0] ?? ""));
    if (!rest[0] || !existsSync(path)) throw new Error(`No such workspace: ${rest[0] ?? ""}`);
    const [ws] = await scanAll((p) => p === path);
    console.log(await generateSummary(ws, opt("model") ?? "haiku"));
    return;
  }

  if (command === "rm") {
    const paths = rest.map((name) => (name.startsWith("/") ? name : join(WORKSPACE_ROOT, basename(name))));
    const missing = paths.filter((p) => !existsSync(p));
    if (missing.length) throw new Error(`No such workspace: ${missing.join(", ")}`);
    const workspaces = await scanAll((p) => paths.includes(p));
    printTable(workspaces);
    if (flags.has("--yes") || (await confirm(`\nDelete ${workspaces.length} workspace(s)?`))) await deleteWorkspaces(workspaces);
    return;
  }

  console.error(USAGE);
  process.exit(1);
};

await main();
