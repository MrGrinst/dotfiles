#!/bin/bash
# Install plannotator from the local fork (MrGrinst/plannotator) instead of the
# official release binary. Runs from source: the launcher shells out to
# `bun apps/hook/server/index.ts`, so edits to the fork are live with no rebuild
# and no 117MB compiled binary to ship. Idempotent — safe to re-run.
set -euo pipefail

REPO="$HOME/Developer/plannotator"
if [[ ! -d "$REPO" ]]; then
  echo "plannotator fork not at $REPO (expected [bootstrap.repos] to clone it); skipping."
  exit 0
fi

# bun comes from Homebrew; make sure it's on PATH even on the first bootstrap run
# before the shell has been re-sourced.
command -v brew >/dev/null 2>&1 || eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || true
if ! command -v bun >/dev/null 2>&1; then
  echo "bun not found (install via Homebrew first); skipping plannotator."
  exit 0
fi

cd "$REPO"

echo "Installing plannotator deps and building the hook UI..."
bun install
# The server embeds apps/hook/dist/{index.html,review.html} at load time, and the
# hook build copies review's built html — so review must build first.
bun run build:review
bun run build:hook

# Put the fork's source launcher on PATH as `plannotator`; bin/plannotator.js runs
# the repo's server via bun, so the plugin hooks and skills all resolve to the fork.
mkdir -p "$HOME/.local/bin"
ln -sf "$REPO/bin/plannotator.js" "$HOME/.local/bin/plannotator"

# The three skills invoke the `plannotator` command and double as /plannotator-*
# slash commands. Symlink (upstream copies) so skill edits in the fork are live.
# Remove any prior copy/link first — `ln -s` into an existing real dir would nest
# the link inside it instead of replacing it.
mkdir -p "$HOME/.claude/skills"
for skill in plannotator-annotate plannotator-last plannotator-review; do
  rm -rf "$HOME/.claude/skills/$skill"
  ln -s "$REPO/apps/skills/claude/$skill" "$HOME/.claude/skills/$skill"
done

# Plan-mode hooks (EnterPlanMode/ExitPlanMode) ship with the plugin at apps/hook.
# Register the fork as a local marketplace and install its plugin, which points the
# hooks at the `plannotator` on PATH above. Don't also add a plannotator hook to
# settings.json — the plugin is the sole source, so it won't double-fire.
if command -v claude >/dev/null 2>&1; then
  echo "Registering the local plannotator plugin with Claude Code..."
  claude plugin marketplace add "$REPO" 2>/dev/null || true
  claude plugin install plannotator@plannotator -y 2>/dev/null || true
fi
