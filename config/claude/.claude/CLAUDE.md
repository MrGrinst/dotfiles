# Comments

- When writing comments, avoid referring to temporal context about refactors or recent changes. Comments should be evergreen and describe the code as it is, not how it evolved or was recently changed.
- Write as FEW comments as possible. Prefer self-documenting code — precise names and small functions — over explaining code with comments. NEVER write a comment that just restates what the code already says.
- Every comment MUST earn its place: capture the *why* a reader can't infer from the code — intent, a non-obvious constraint, a gotcha, a reference. If a comment doesn't tell the reader something the code cannot, don't write it.
- Keep every comment concise — a short phrase or sentence. No banner blocks, decorative separators, or step-by-step narration of the code.

# Version control

jj is my preferred VCS. Start new projects with `jj git init`, and in an existing
git repo without `.jj/`, colocate one with `jj git init --colocate` before working.

- The working copy `@` snapshots on every jj command — there is no staging step,
  so `jj describe` stands in for add-then-commit.
- Bookmarks replace branches and sit on `@-`, since `@` is the open change.
