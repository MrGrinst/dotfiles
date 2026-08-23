# Runs for EVERY zsh invocation, including non-interactive scripts (`zsh -c …`)
# and cron/launchd/GUI-spawned shells that never source ~/.profile or ~/.zshrc.
# Interactive and login shells additionally run `mise activate` (via ~/.profile)
# for per-directory version switching; these shims are the fallback for the rest.
if [ -d "$HOME/.local/share/mise/shims" ]; then
  case ":$PATH:" in
  *":$HOME/.local/share/mise/shims:"*) ;;
  *) export PATH="$HOME/.local/share/mise/shims:$PATH" ;;
  esac
fi
