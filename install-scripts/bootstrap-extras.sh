#!/bin/bash
# Imperative setup mise's declarative bootstrap steps don't cover. Run as the
# `bootstrap` task (last step of `mise bootstrap`), after Homebrew, dotfiles, and
# the mise tool install — so gh/node/claude are already on PATH. Idempotent.
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

if [[ ! -f ~/.ssh/id_ed25519 ]]; then
  echo "Generating machine's ssh key..."
  ssh-keygen -t ed25519 -C "kyle@grinsteadfam.com" -P "" -f ~/.ssh/id_ed25519
fi

# tmux plugin manager (tpm) is cloned declaratively by [bootstrap.repos].

# Accept the Xcode license once the full Xcode app is present (installed via mas).
# brew's sudo keepalive is long gone by now, so re-acquire root first.
if command -v xcodebuild >/dev/null 2>&1; then
  echo "Accepting the Xcode license..."
  sudo -v && sudo xcodebuild -license accept || true
fi

# Claude Code: marketplace + user-enabled plugins
if command -v claude >/dev/null 2>&1; then
  echo "Configuring Claude Code plugins..."
  claude plugin marketplace add anthropics/claude-plugins-official 2>/dev/null || true
  claude plugin install mattpocock-skills@claude-plugins-official -y 2>/dev/null || true
fi

# gh backs PR/repo flows (glab too for GitLab) and general dev; log in once.
# plannotator is built from the local fork by the `plannotator` task, not here.
if ! gh auth status >/dev/null 2>&1; then
  echo "Authenticating gh..."
  gh auth login || echo "gh auth failed; skipping."
fi
