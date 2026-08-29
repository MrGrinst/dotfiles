# Runs for EVERY zsh invocation, including non-interactive scripts (`zsh -c …`)
# and cron/launchd/GUI-spawned shells that never source ~/.profile or ~/.zshrc.
# Interactive and login shells additionally run `mise activate` (via ~/.profile)
# for per-directory version switching; these shims are the fallback for the rest.

# Homebrew bin (nvim, ripgrep, …): interactive shells pick this up from ~/.profile,
# but non-interactive ones — like the shell tmux spawns to open a file in nvim —
# need it here or Homebrew tools resolve to "command not found".
brew_bin="${HOMEBREW_PREFIX:-/opt/homebrew}/bin"
if [ -d "$brew_bin" ]; then
  case ":$PATH:" in
  *":$brew_bin:"*) ;;
  *) export PATH="$brew_bin:$PATH" ;;
  esac
fi
unset brew_bin

if [ -d "$HOME/.local/share/mise/shims" ]; then
  case ":$PATH:" in
  *":$HOME/.local/share/mise/shims:"*) ;;
  *) export PATH="$HOME/.local/share/mise/shims:$PATH" ;;
  esac
fi
