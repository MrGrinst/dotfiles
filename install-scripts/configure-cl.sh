#!/bin/bash
set -euo pipefail

if [[ ! -f ~/.ssh/id_ed25519 ]]; then
  echo "Generating machine's ssh key..."
  ssh-keygen -t ed25519 -C "kyle@grinsteadfam.com" -P "" -f ~/.ssh/id_ed25519
  echo
fi

# Make Homebrew's zsh the login shell. chsh refuses shells that aren't listed in
# /etc/shells, so whitelist it first.
brew_zsh="$(brew --prefix)/bin/zsh"
if ! grep -qxF "$brew_zsh" /etc/shells; then
  echo "$brew_zsh" | sudo tee -a /etc/shells >/dev/null
fi
[ "$SHELL" = "$brew_zsh" ] || chsh -s "$brew_zsh"

# Setup tmux
if [[ ! -d ~/.tmux/plugins/tpm ]]; then
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# Claude config lives in dirs full of generated state. Pre-create them as real
# dirs so stow links individual files instead of folding the whole dir into a
# symlink. Bail if a file we manage already exists as real (non-symlink) content
# so we don't clobber a machine's existing Claude config; already-stowed symlinks
# are fine and get relinked below.
mkdir -p ~/.claude/skills
for f in ~/.claude/CLAUDE.md ~/.claude/settings.json; do
  if [[ -e "$f" && ! -L "$f" ]]; then
    echo "Error: $f already exists and isn't a symlink; move it aside before running." >&2
    exit 1
  fi
done

# Stow (-R restows, so re-running doesn't conflict on already-linked packages)
rm -f ~/.zshrc
cd "$(dirname "$(readlink -f "$0")")/../config"
stow -R --target "$HOME" \
  Aerospace \
  Karabiner \
  assorted-cli \
  claude \
  ghostty \
  git \
  jj \
  macos-defaults \
  nvim \
  sesh \
  shells \
  starship \
  tmux

echo "Installing languages via mise... (major.minor pins resolve to the latest patch at install time)"
mise use -g erlang@28
mise use -g elixir@1.20.3-otp-28   # OTP-tagged build must match the erlang major above
mise use -g node@24
mise use -g python@3.14

echo "Installing fnox (secrets manager) via mise..."
mise use -g fnox
echo

# starship-jj renders jj status in the prompt (starship has no native jj module)
echo "Installing starship-jj via mise..."
mise use -g "cargo:starship-jj" || echo "starship-jj install failed (cargo backend); skipping."
echo

# bun is installed via Homebrew (see Brewfile) rather than its curl|bash
# installer, so it's checksum-verified and updates with `brew upgrade`.

# Claude Code: marketplace + user-enabled plugins
if command -v claude >/dev/null 2>&1; then
  echo "Configuring Claude Code plugins..."
  claude plugin marketplace add anthropics/claude-plugins-official 2>/dev/null || true
  claude plugin install mattpocock-skills@claude-plugins-official -y 2>/dev/null || true
  echo
fi

# plannotator's provenance check runs `gh attestation verify`, which needs an
# authenticated gh. Log in first so verification can pass on a fresh machine.
if ! gh auth status >/dev/null 2>&1; then
  echo "Authenticating gh (needed for plannotator's provenance check)..."
  gh auth login || echo "gh auth failed; plannotator's provenance check will likely be skipped."
  echo
fi

# plannotator (annotate/review CLI) — its installer also installs plannotator's
# own Claude skills into ~/.claude/skills, so those aren't tracked here. Rather
# than piping the installer into a shell, download it to a file and require SLSA
# build-provenance verification of the downloaded binary (via `gh attestation
# verify`); the install fails closed if that check can't pass. Installs the
# latest release; verification is what protects the download, not a pinned tag.
echo "Installing plannotator (latest, provenance-verified)..."
pt_installer="$(mktemp)"
if curl -fsSL "https://plannotator.ai/install.sh" -o "$pt_installer"; then
  bash "$pt_installer" --verify-attestation --no-extras --yes \
    || echo "plannotator install failed (provenance check or download); skipping."
fi
rm -f "$pt_installer"
echo
