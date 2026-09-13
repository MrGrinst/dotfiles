#!/usr/bin/env bash
# Agents write BSD's `sed -i ''` on macOS, but gnubin puts GNU sed first, which reads '' as the script.

cmd=$(jq -r '.tool_input.command // empty')
printf '%s' "$cmd" | grep -Eq "(^|[^[:alnum:]_-])sed[[:space:]][^|;&]*-i[[:space:]]+(''|\"\")" || exit 0
sed --version 2>/dev/null | grep -q GNU || exit 0

jq -n '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",
  permissionDecisionReason:"sed here is GNU sed: drop the empty suffix and write sed -i '\''s/…/…/'\'' file."}}'
