# Dotfiles

Scripts and configuration to take a fresh macOS install to a fully set-up machine:
Homebrew packages, CLI tooling, shell/editor/terminal config, and declarative
system preferences.

## Install

This repo expects to live at `~/Developer/dotfiles` — several configs reference that
path directly (shell `PATH`, git `hooksPath`, jj helpers), so clone it there:

```sh
git clone <this-repo> ~/Developer/dotfiles
cd ~/Developer/dotfiles/install-scripts
./install.sh
```

`install.sh` is idempotent — safe to re-run — and drives the whole setup:

1. Installs Homebrew (which pulls in the Xcode command line tools) and everything in
   [`Brewfile`](install-scripts/Brewfile).
2. Runs [`configure-cl.sh`](install-scripts/configure-cl.sh): generates an SSH key,
   makes Homebrew `zsh` the login shell, installs [tpm](https://github.com/tmux-plugins/tpm),
   symlinks every config package with GNU Stow, installs language runtimes via
   [`mise`](https://mise.jdx.dev) plus `starship-jj` (jj status in the prompt),
   installs `plannotator` (downloaded and provenance-verified rather than
   piped into a shell), and restores Claude Code plugins from their marketplace
   — including `mattpocock-skills`, which provides the Claude skills.
3. Runs [`configure-system-prefs.sh`](install-scripts/configure-system-prefs.sh):
   applies the declarative macOS defaults under `config/macos-defaults/`.

## Layout

`config/` holds one [GNU Stow](https://www.gnu.org/software/stow/) package per tool.
Each package mirrors the layout it should have relative to `$HOME`, so
`stow`-ing it symlinks the files into place:

| Package          | Symlinks                                    |
| ---------------- | ------------------------------------------- |
| `shells`         | `~/.zshrc`, `~/.profile`, `~/.aliases`, …   |
| `git`            | `~/.gitconfig`, global hooks & ignore       |
| `nvim`           | `~/.config/nvim/`                           |
| `tmux`           | `~/.tmux.conf`                              |
| `starship`       | `~/.config/starship.toml`                   |
| `jj` / `sesh`    | `~/.config/{jj,sesh}/`                       |
| `claude`         | `~/.claude/{CLAUDE.md,settings.json}`       |
| `ghostty`, `Karabiner`, `Aerospace`, `assorted-cli`, `macos-defaults` | their respective config paths |

`bin/` holds standalone scripts (jj workspace/PR helpers, tmux session tooling); it's
added to `PATH` in `.profile`.

`~/.claude` is full of generated state (sessions, caches, plugin checkouts), so the
`claude` package tracks only the hand-owned pieces (`CLAUDE.md`, `settings.json`).
Skills and their dependencies come from Claude Code plugins, declared in
`settings.json`'s `enabledPlugins` and installed from their marketplaces by
`configure-cl.sh` — not vendored here. `configure-cl.sh` pre-creates `~/.claude` before
stowing so the whole directory isn't folded into a single symlink.

To (re)link a single package after changes:

```sh
cd ~/Developer/dotfiles/config
stow -R --target "$HOME" <package>
```

## Credits

Drawn heavily from:

- https://github.com/Netherdrake/Dotfiles
- https://github.com/mhartington/dotfiles
- https://github.com/nicknisi/dotfiles
- https://github.com/aaronbieber
- https://github.com/r00k/dotfiles
