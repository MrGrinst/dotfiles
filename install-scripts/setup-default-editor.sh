#!/usr/bin/env bash
# Build NeovimTmux.app from its AppleScript source and register it as the default
# handler for text/code files, so opening a file from Finder/other apps routes
# through bin/nvim-open into tmux+nvim. Idempotent — rebuilds every run.
set -euo pipefail

BUNDLE_ID="com.kylegrinstead.neovim-tmux"
APP_NAME="NeovimTmux"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="${REPO_ROOT}/apps/${APP_NAME}.applescript"
APP_DIR="${HOME}/Applications/${APP_NAME}.app"
PLIST="${APP_DIR}/Contents/Info.plist"
LSREGISTER="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister"

# Broad content types this editor claims. Files whose own UTI has no competing
# handler resolve here via conformance.
CONTENT_TYPES=(
  public.plain-text
  public.source-code
  public.shell-script
  public.script
  public.json
  public.xml
  public.yaml
  public.css
  net.daringfireball.markdown
)

# Extensions whose concrete UTI another app claims (browser, Xcode, VLC, …).
# LaunchServices resolves the most specific UTI first, so these must be set by
# extension to actually win over the default handler.
EXTENSIONS=(
  txt md markdown
  sh bash zsh fish
  py rb pl lua vim
  js jsx ts tsx mjs cjs
  jsonc yml toml
  html htm scss sass less
  svg
  c h cpp hpp cc cxx
  go rs zig
  java kt kts scala
  swift m mm
  sql graphql gql proto
  tf hcl
  ex exs erl hrl
  hs elm
  conf cfg ini env
  csv tsv log
  diff patch
)

command -v duti >/dev/null 2>&1 || {
  echo "duti is required (brew install duti)." >&2
  exit 1
}

echo "Building ${APP_DIR} from ${SRC}..."
rm -rf "$APP_DIR"
mkdir -p "${HOME}/Applications"
osacompile -o "$APP_DIR" "$SRC"

pb() { /usr/libexec/PlistBuddy -c "$1" "$PLIST"; }
pb "Set :CFBundleIdentifier ${BUNDLE_ID}" 2>/dev/null || pb "Add :CFBundleIdentifier string ${BUNDLE_ID}"
pb "Delete :CFBundleDocumentTypes" 2>/dev/null || true
pb "Add :CFBundleDocumentTypes array"
pb "Add :CFBundleDocumentTypes:0 dict"
pb "Add :CFBundleDocumentTypes:0:CFBundleTypeName string Text"
pb "Add :CFBundleDocumentTypes:0:CFBundleTypeRole string Editor"
pb "Add :CFBundleDocumentTypes:0:LSItemContentTypes array"
type_index=0
for uti in "${CONTENT_TYPES[@]}"; do
  pb "Add :CFBundleDocumentTypes:0:LSItemContentTypes:${type_index} string ${uti}"
  type_index=$((type_index + 1))
done

# Teach LaunchServices the freshly built bundle id -> path before duti sets defaults.
"$LSREGISTER" -f "$APP_DIR"

echo "Setting ${APP_NAME} as the default editor..."
set_default() {
  local type="$1"
  if duti -s "$BUNDLE_ID" "$type" editor 2>/dev/null; then
    echo "  ✓ $type"
  else
    echo "  ✗ $type (skipped)"
  fi
}
for uti in "${CONTENT_TYPES[@]}"; do set_default "$uti"; done
for ext in "${EXTENSIONS[@]}"; do set_default ".$ext"; done

echo "Done."
