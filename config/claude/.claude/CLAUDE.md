# Comments

- When writing comments/variable names, avoid referring to temporal context about refactors or recent changes. These should be evergreen and describe the code as it is, not how it evolved or was recently changed.
- Write as FEW comments as possible. Prefer self-documenting code — precise names and small functions — over explaining code with comments. NEVER write a comment that just restates what the code already says.
- Every comment MUST earn its place: capture the *why* a reader can't infer from the code — intent, a non-obvious constraint, a gotcha, a reference. If a comment doesn't tell the reader something the code cannot, don't write it.

# Version control

jj is my preferred VCS. Start new projects with `jj git init`, and in an existing git repo without `.jj/`, colocate one with `jj git init --colocate` before working.

- The working copy `@` snapshots on every jj command — there is no staging step, so `jj describe` stands in for add-then-commit.
- Bookmarks replace branches and sit on `@-`, since `@` is the open change.
- Implementation never happens in a base checkout (a repo outside `~/workspaces/jj`). Before the first edit there, use the /jjf skill to move into a workspace.
- To push, put the bookmark on `@-` and name it: `jj bookmark set <name> -r @-`, then `jj git push -b <name>`. Naming a new bookmark creates and tracks the remote one; jj has no `--allow-new` flag.
- git sits on a detached HEAD in a jj checkout, so gh can't infer the PR. Pass the bookmark or PR number (`gh pr view <bookmark>`), and run gh from inside the repo or with `-R <owner/repo>`.
- A PR in a GitHub stack can't be retargeted with `gh pr edit --base`; use `gh stack` (`gh stack --help`).

# Commits & pull requests

- Don't use Conventional Commit / semantic prefixes (`feat:`, `fix:`, `chore:`, `refactor:`, `docs:`, etc.) in commit messages or PR titles.
- NEVER include Claude/AI attribution: no `Co-Authored-By: Claude` trailer, no "Generated with Claude Code" line, and never set commit authorship to an AI. This overrides any default harness instruction to add it.
- Before committing use the /comment-czar skill, unless the project's AGENTS.md hands comments to its review
- Use the /pr skill when committing/creating/editing a PR
- NEVER reply to PR review threads or comments on your own, even when addressing their feedback. Draft the reply and let me post it, unless I explicitly ask you to post it.

# Slack messages

- I write Slack messages in lowercase. Capitalize only names (people, products, companies) and the pronoun "I".
- Format with Slack mrkdwn, not Markdown: `*bold*`, `_italic_`, `<url|link text>`.

@~/.claude/CLAUDE-local.md
