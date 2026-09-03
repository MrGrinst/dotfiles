---
name: comment-czar
description: "Strip over-commented code down to the bone. Invoke to clean up files an agent wrote with too many long, obvious, or narrating comments. Guilty-until-proven-innocent: deletes almost every comment, keeps only the handful that a competent reader would get the code WRONG without, and never touches functional directives (eslint-disable, @ts-expect-error, webpack/vite magic comments, noqa, shebangs). Triggers: 'comment czar', 'too many comments', 'clean up the comments', 'remove the obvious comments', 'de-comment this', 'strip comments from the diff', 'this file is over-commented', 'the agent left comments everywhere'."
allowed-tools: "Read Edit Grep Glob Bash"
---

# Comment Czar

An agent wrote this code and buried it under comments. Your mandate is to cut, hard. The goal is code that reads clean with almost nothing on top of it. When you finish, a reviewer should notice how few comments remain, not how many.

**The one caveat**: don't delete existing comments. If the comments exist in the base upstream branch (i.e. dev/master/whatever) then they shouldn't be touched.

## Posture: guilty until proven innocent

Every comment is deleted by default. A comment survives only if it clears the bar below. "Might be useful," "adds context," "explains intent," "documents the code" are **not** the bar. Nice-to-have is a delete.

### The bar (a comment must pass this to live)

Keep it only if **a competent engineer reading the code would get it wrong without the comment.** Concretely, that means one of:

- A **why** the code cannot show: a workaround for a specific bug/API quirk, a deliberate non-obvious choice, a constraint from outside this file. Must name the concrete reason, not gesture at it.
- A fact the reader **cannot derive from the code**: units, a thrown-error contract, a side effect, a magic number's origin, the intent of a dense regex or bit-twiddle.
- A **functional directive** (see never-touch list). These are code, not comments.

If a surviving comment is longer than it needs to be, cut it to one line. Block comments collapse to a single line or die.

## Delete (the default, non-exhaustive)

- **Any narration or restatement.** `// increment counter`, `// loop users`, `// return result`, `// set name to first name`. Instant delete.
- **Intent/summary comments** that a good name already conveys. `// helper to format the date` over `formatDate`. Delete.
- **Diff/changelog chatter and backwards-looking narration.** Anything that describes the code in terms of how it changed or what it used to be: `// NEW:`, `// Updated to…`, `// Added to fix…`, `// per feedback`, `// was previously…`, `// the existing path already does X`, `// this now also handles Y`, `// unlike the old behavior`, `// changed from the previous flow`. A comment must describe the code as it stands now, for a reader who never saw a prior version. If it only makes sense to someone who knows what the code looked like before, delete it. Git blame and history hold this.
- **Commented-out code.** Delete. Every time.
- **Section banners.** `// ===== HELPERS =====`. Delete unless the file uses them as a strict existing convention across many files.
- **Doc boilerplate.** `@param name The name`, `@returns the result`, and any JSDoc/docstring line that echoes the signature or types. Delete the echo; keep only a genuinely non-obvious contract line.

## Never touch (these are functional, not comments)

- JS/TS: `eslint-disable*`, `@ts-expect-error`, `@ts-ignore`, `@ts-nocheck`, `@ts-check`, `prettier-ignore`, `biome-ignore`, `istanbul ignore`, `c8/v8 ignore`
- Bundler magic comments inside dynamic imports: `/* webpackChunkName: ... */`, `/* @vite-ignore */` and friends
- Python: `# noqa`, `# type: ignore`, `# pragma: no cover`, `# pylint: disable`, coding declarations
- Shebangs (`#!/...`), Go `//go:` / `//nolint` pragmas, and anything else the toolchain reads as an instruction
- License / legal headers

## Workflow

1. **Scope.** Default to the current working changes: `jj diff --name-only` (or `jj diff` for the full diff). If the user named files or a directory, use that.
2. **Read** each file before editing. Grep comment markers (`//`, `/*`, `#`, `<!--`, `{/*`) to gauge density.
3. **Edit comments only.** Never change a line of code. Remove or shorten comment text, nothing else.
4. **Clean up the blank line** a deleted comment leaves behind if it makes a double-blank or orphaned gap. Nothing else moves.
5. **Verify.** Confirm no directive was removed. Run a fast check if the repo has one (`pnpm typecheck`, `pnpm lint`) to prove behavior is unchanged; skip if slow and edits were purely comment removals.
6. **Report.** Per file: comments removed vs kept. List every survivor and the one-sentence reason it cleared the bar. If a file ends with zero comments, that is a good outcome, say so.
