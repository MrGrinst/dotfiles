---
name: pr
description: "Write or update a commit or pull request for the current change. Use when opening a PR, drafting/editing a PR description, or writing a commit message.Triggers: 'open a pr', 'draft the pr', 'write the pr description', 'pr for this', 'commit this', 'write a commit message', 'ship this', 'update the PR desc'."
allowed-tools: "Read Grep Glob Bash"
---

# Commit & PR

## Commit message

- Commit messages should always be single line.

## PR description

- The description is short and conversational; the most important piece is a verified testing plan. Default to terse.
- NEVER overwrite an existing PR description from scratch. Pull the live body first (`gh pr view <n> --json body -q .body`), apply changes on top of that text, and pass the merged result to `gh pr edit --body-file`.

## Flow

1. **Diff against the base branch.** If the change is stacked or cross-repo, note the stacking and deploy order in the description.
2. **Read the repo's pull request template file** if present and fill it in. Output plain markdown; strip HTML comments.
3. **Description**: 1-3 sentences on what the change does and any context a reviewer needs. No padding. (Load the `writing-voice` skill for this.)
4. **Testing Plan** (the substance): if a `test-plan` skill exists, load it and follow it. Otherwise, structure a manual plan as Setup → Execute → Verify, and run every command locally before it goes in. Never output an unverified command.
5. **Deploy notes**: `Safe to deploy`, or the migration / stacking / deploy-order steps. It should always be a checklist.

## Before opening the PR

- **Issue tracker link**: confirm the change is linked to an issue (e.g. a `{PROJECT}-{NUMBER}` identifier in the branch name, commits, or PR body). If none, stop and ask whether to create one or link an existing one. Don't open the PR until that's resolved.
- Create it as a **draft**.
