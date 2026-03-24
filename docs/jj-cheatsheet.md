# `jj` Cheatsheet for Kyle

## Common shortcuts

| What you want | Command |
| --- | --- |
| Start a fresh change on latest trunk | `jl` |
| Start a named workspace, even if the name is temporary | `jjf [name]` |
| Relink the current temp workspace to the final Linear branch name | `jjf-link [final-name]` |
| See current status | `js` |
| Commit the current change | `jc -m "message"` |
| Commit, advance, and push an already-bookmarked change | `jap -m "message"` |
| Amend/fold follow-up edits | `ja` |
| Put a feature bookmark on the current change | `jbm my-change` |
| Advance and push the current feature bookmark | `jp` |
| Amend and push | `japa` |
| Push and create/open PR for the current feature bookmark | `jph` |
| Rebase current work onto latest trunk | `jr` |
| See detected trunk bookmark | `jt` |
| Duplicate another change onto current work | `jcp <rev> -o @` |

`jl` and `jr` auto-detect trunk as `dev`, `main`, or `master`.
`jjf` always requires a name. If you do not pass one, it prompts until you enter one.
For new workspaces, `jjf` uses the entered text as the initial change description and derives a normalized workspace/bookmark slug from it.
If the entered text exactly matches a local bookmark or an `origin` bookmark, `jjf` reuses that branch instead of creating a new suffixed bookmark.
If that branch already has a known workspace directory or tmux session, `jjf` reopens it instead of creating another one.
If that slug already exists, `jjf` appends `-2`, `-3`, etc. to keep the workspace/bookmark/path unique.
`jjf-link` applies the same suffixing rules if the final branch name is already taken, but it now keeps the underlying workspace directory in place and only renames the logical branch/workspace/session identity.
`jp` and `jph` only auto-pick a bookmark when exactly one non-trunk bookmark points at `@-`.
`dev`, `main`, and `master` are treated as protected trunk bookmarks and are never advanced by these helpers.
`jph` derives PR base from the parent bookmark when it can do so unambiguously. Otherwise pass `jph <bookmark> <base>`.

## Temp-to-Linear flow

```bash
jjf
# prompted for a required temp name like:
# "debug billing timeout"
# creates a workspace/bookmark/path from a normalized slug

# later, once you know the final Linear branch name
jjf-link eng-1234-fix-billing-timeout
```

You can also seed the temp workspace directly:

```bash
jjf "debug billing timeout"
```

## Daily flow

```bash
jl
# edit files
js
jc -m "clear commit message"
jbm my-change
# more edits
ja
jp
```

## Explicit equivalents

Each shortcut stays close to raw `jj`:

```bash
jl            # jj git fetch && jj new "$(jt)"@origin
jjf "rough idea" # promptless start; creates a unique temp workspace/bookmark/path
jjf-link final-linear-branch # rename current workspace/bookmark/path to the final branch name
jr            # jj git fetch && jj rebase -b @ -d "$(jt)"@origin
jbm my-change # jj bookmark set my-change -r @-
jp            # resolve one non-trunk bookmark on @-, advance it, then push it
japa          # jj squash && jp
jap -m "msg"  # jj commit -m "msg" && jp
jph           # resolve/set one non-trunk bookmark on @-, then gh pr create/view
```

## Useful primitives

```bash
jj new <rev>
jj commit -m "message"
jj squash
jj rebase -b @ -d main@origin
jj bookmark advance --to @-
jj bookmark set my-change -r @-
jj git push --bookmark my-change
jj duplicate <rev> -o @
```

## Think in `jj`, not Git

- There is no checked-out branch.
- Bookmarks are names that point at revisions.
- Use bookmarks when you are ready to share a change.
- Keep `dev`, `main`, and `master` as fixed trunk bookmarks. Use separate feature bookmarks for work you push.
- `jj squash` is your new amend.
- `jj duplicate` is your new cherry-pick.
- `jj undo` is the panic button you should remember first.
- Prefer explicit revision and bookmark names over helper scripts that guess.

## Safety commands

```bash
jj undo
jj op log
jj log
jj diff
jj status
```
