# Dotfiles

Scripts and configuration to take a fresh macOS install to a fully set-up machine:
Homebrew packages, CLI tooling, shell/editor/terminal config, language runtimes, and
declarative system preferences — driven by a single [`mise`](https://mise.jdx.dev)
manifest.

This repo expects to live at `~/Developer/dotfiles` — several configs reference that
path directly (shell `PATH`, git `hooksPath`, jj helpers, `dotfiles.root`), so clone
it there.

## Install (mise bootstrap)

[`mise.toml`](mise.toml) is the source of truth. `mise bootstrap` reads it and
converges the machine in one command — each declarative section is skipped when
already in its desired state, so it's safe to re-run.

```sh
git clone <this-repo> ~/Developer/dotfiles && cd ~/Developer/dotfiles
curl https://mise.run | sh          # install mise (or: brew install mise)
mise trust && mise bootstrap
```

`mise bootstrap` runs these steps in order:

1. **Homebrew** (`pre-packages` hook → [`bootstrap-brew.sh`](install-scripts/bootstrap-brew.sh)):
   installs Homebrew (which pulls in the Xcode command line tools) and everything in
   [`Brewfile`](install-scripts/Brewfile). Runs first so brew's `zsh` and CLI tools
   exist before the login-shell and tool-install steps.
2. **Git checkouts** (`[bootstrap.repos]`) then **dotfiles** (`[dotfiles]`): clones
   [tpm](https://github.com/tmux-plugins/tpm) into `~/.tmux/plugins/` and the
   [plannotator fork](https://github.com/MrGrinst/plannotator) into `~/Developer/`,
   then symlinks every config file/dir into `$HOME`. Sources point straight at the
   `config/**` files, so nothing is copied or moved. Existing dirty checkouts are
   left alone (never reset).
3. **macOS defaults** (`[bootstrap.macos.defaults]`, in
   [`.mise/conf.d/macos-defaults.toml`](.mise/conf.d/macos-defaults.toml) — mise
   auto-merges every `.mise/conf.d/*.toml` when run from this repo), then a
   `post-defaults` hook
   ([`macos-defaults-extras.sh`](install-scripts/macos-defaults-extras.sh)) for the
   settings the declarative table can't express (an empty-array Dock key, a per-host
   Control Center key, sudo/system-plist writes) and to restart the affected apps.
4. **Login shell** (`[bootstrap.user]`): `chsh` to Homebrew's `zsh`.
5. **Tools** (`[tools]`): installs the language runtimes (erlang, elixir, node,
   python, ruby), `fnox` (secrets), and `cargo:starship-jj` (jj status in the prompt).
6. **`bootstrap` task** ([`bootstrap-extras.sh`](install-scripts/bootstrap-extras.sh)):
   the imperative leftovers — ssh key, Claude Code plugins (incl. `mattpocock-skills`),
   `gh auth login`, and the Xcode license. It depends on the **`plannotator` task**
   ([`plannotator-from-source.sh`](install-scripts/plannotator-from-source.sh)), which
   builds [the fork](https://github.com/MrGrinst/plannotator) from source (`bun install`
   + build), symlinks its launcher onto `PATH` as `plannotator`, symlinks its three
   Claude skills, and registers its local plugin for the plan-mode hooks. Both run
   last, with the tools already on `PATH`. Rebuild after pulling the fork with
   `mise run plannotator`.

Homebrew stays the real installer for CLI formulae, casks, and Mac App Store apps
(`mas`); mise orchestrates it and owns the language runtimes.

## Testing on a fresh machine (without touching this one)

[`bin/test-bootstrap`](bin/test-bootstrap) exercises the setup safely:

```sh
test-bootstrap
```

It runs read-only previews on this machine (`mise bootstrap --dry-run`, a real-home
`dotfiles apply -n`, and `macos defaults status`), then does a **real** `[dotfiles]`
apply into a throwaway `$HOME` (via `mktemp -d` and sandboxed `MISE_*` dirs) to prove
every symlink resolves — without writing to your real home directory. The
machine-global parts (Homebrew, login shell, macOS defaults) and the heavy tool
install stay preview-only; they're only truly exercised by running `mise bootstrap`
on an actual fresh machine.

## Layout

`config/` holds one directory per tool, each mirroring the layout it should have
relative to `$HOME`. The `[dotfiles]` table in `mise.toml` maps each target path to
its source here:

| Package          | Symlinks                                    |
| ---------------- | ------------------------------------------- |
| `shells`         | `~/.zshrc`, `~/.profile`, `~/.aliases`, …   |
| `git`            | `~/.gitconfig`, `~/.gitignore_global`       |
| `nvim`           | `~/.config/nvim/`                           |
| `tmux`           | `~/.tmux.conf`                              |
| `starship`       | `~/.config/starship.toml`, `~/.config/starship-jj/` |
| `jj` / `sesh`    | `~/.config/{jj,sesh}/`                       |
| `claude`         | `~/.claude/{CLAUDE.md,settings.json}`       |
| `ghostty`, `Karabiner`, `Aerospace`, `assorted-cli` | their respective config paths |

`bin/` holds standalone scripts (jj workspace/PR helpers, tmux session tooling); it's
added to `PATH` in `.profile`.

`~/.claude` is full of generated state (sessions, caches, plugin checkouts), so only
the hand-owned files (`CLAUDE.md`, `settings.json`) are symlinked — as individual
files, not the whole directory. Skills and their dependencies come from Claude Code
plugins, declared in `settings.json`'s `enabledPlugins` and installed from their
marketplaces by `bootstrap-extras.sh` — not vendored here.

To re-apply dotfiles after changing which files `mise.toml` tracks:

```sh
mise bootstrap dotfiles apply        # add -n to preview, -f to overwrite conflicts
```

## Credits

Drawn heavily from:

- https://github.com/Netherdrake/Dotfiles
- https://github.com/mhartington/dotfiles
- https://github.com/nicknisi/dotfiles
- https://github.com/aaronbieber
- https://github.com/r00k/dotfiles
