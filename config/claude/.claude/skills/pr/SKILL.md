---
name: pr
description: "Write or update a commit or pull request for the current change. Use when opening a PR, drafting/editing a PR description, or writing a commit message.Triggers: 'open a pr', 'draft the pr', 'write the pr description', 'pr for this', 'commit this', 'write a commit message', 'ship this', 'update the PR desc'."
allowed-tools: "Read Grep Glob Bash"
---

# Commit & PR

## Title

- Lowercase, imperative, conversational. Say what the change does, not what area it touches.
- Describe the behavior as it will be after merge, so it reads right to someone who never saw earlier names or attempts.
- No ticket ID or issue key. No Conventional-Commit / semantic prefix (`feat:`, `fix:`, `chore:`, etc.).

## Commit message

- One subject line. Add a body only when the repo's own instructions (its `AGENTS.md` or `CLAUDE.md`) ask for one, in exactly the shape they ask for; otherwise the message is that single line.

## PR body

Kyle writes the description himself, and it's the top-level section reviewers read first. The agent writes a short placeholder there and puts its own material in a collapsed **Agent notes** `<details>` block right below it, so the two never mix.

```markdown
# Kyle's description

- [<what changes for a user or caller>]
- [<why: the problem or ticket context>]
- [<anything a reviewer needs: a tradeoff, what was left alone on purpose>]

<details>
<summary>

# Agent notes

</summary>

### Summary

<the one visual that makes the change clear>

### Evidence

**Before:** <failing test, output, query counts, screenshot>
**After:** <the same, after the change>

### Merge Danger

**Door:** <one-way | two-way>, <why, in one line>
**Blast radius:** <one word>, <callers checked and which ones change behavior>

</details>

# Testing Plan

# Deploy Notes

# Checklist
```

When the repo has a pull request template, keep its headings and order, rename its Description heading to `# Kyle's description`, and insert the Agent notes block right after it. The `# Agent notes` heading sits inside `<summary>` so it reads as a top-level section beside the template's `#` headings while staying collapsed. Output plain markdown with HTML comments stripped. GitHub only renders markdown inside `<details>` and `<summary>` when blank lines surround it, so keep the blank lines around `# Agent notes`, after `</summary>`, and before `</details>`.

- **Kyle's description**: raw notes for Kyle to reword, each wrapped in `[...]` so it reads as a draft. Short bullets with the actual facts (names, counts, the ticket's problem), not prose. Use a `###` group of bullets per topic only when the change has several distinct parts. After Kyle edits any of it, the section is his: leave it untouched on every later edit.
- **Agent notes**: load `mattpocock-skills:pr` for its menu of Summary visuals and its Evidence tiers; the layout above replaces its template. Pick the smallest visual that makes the point. Blast radius comes from legwork: grep every caller of each changed function or predicate, in this repo and in any sibling repo that consumes it. When the change touches raw SQL, Evidence includes its `EXPLAIN`. When it changes matching or routing, Evidence includes before/after backtest counts in a table.
- **Testing Plan** (the substance): if a `test-plan` skill exists, load it and follow it. Otherwise, structure a manual plan as Setup → Execute → Verify, and run every command locally before it goes in. Never output an unverified command.
- **Deploy Notes**: a checklist of only the steps Kyle has to perform by hand after merge, one line each: a manual backfill or data script, a Retool change, a config or env update, a cross-repo deploy order. Anything CI does on deploy is never a deploy note, and neither is a dependency PR or ticket that's already merged. When nothing is manual, the checklist is a single `Safe to deploy`.
- **Checklist**: split the template's checklist into two labeled groups:
  - **You'll need to do:** items only Kyle can own. Always leave self-review to him (never check it). Add any genuinely manual step.
  - **Verified by agent:** for each test-plan case that can be checked programmatically or by inspection, spin off a sub-agent to verify it. One line per thing an agent actually confirmed; only check a box after an agent verified it.

## Editing a live PR body

- Every edit starts by re-fetching the live body: `gh pr view <n> --json body -q .body > /tmp/pr-<n>.md`. Kyle or a bot may have edited it since your last push, so re-fetch before each `gh pr edit`, not once per session.
- Make surgical edits to that file with Edit. If the fetched body differs from what you last pushed, the live version is the base: re-apply only your intended deltas onto it.
- Confirm each new string is in the file (`grep -c`), then run `gh pr edit <n> --body-file /tmp/pr-<n>.md` as its own call.

## Before opening the PR

- **Diff against the base branch.** Mention a stacked dependency PR only while it's still open, as one line in Deploy Notes.
- **Issue tracker link**: the branch name carries the issue (`{PROJECT}-{NUMBER}`), so the body never repeats it. If the branch has no issue key, stop and ask whether to create an issue or link an existing one, then rename the branch (the `jjf` skill). Don't open the PR until that's resolved.
- Create it as a **draft**.
