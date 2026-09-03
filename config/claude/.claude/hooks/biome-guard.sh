#!/usr/bin/env bash
# Steer Claude to Biome when it reaches for ESLint/Prettier in a repo that uses Biome.
#
# Runs as a PreToolUse(Bash) hook: reads the tool-call JSON on stdin, and denies the
# command (feeding a corrective reason back to Claude) ONLY when the current repo has
# a Biome config. Repos without a biome.json/biome.jsonc are left completely alone, so
# ESLint/Prettier still work everywhere else.

input=$(cat)
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty')
cwd=$(printf '%s' "$input" | jq -r '.cwd // empty')

[ -z "$cmd" ] && exit 0

tool=""
if printf '%s' "$cmd" | grep -Eqw 'eslint'; then
  tool="ESLint"; kw="lint|check"; cli="biome lint / biome check"
elif printf '%s' "$cmd" | grep -Eqw 'prettier'; then
  tool="Prettier"; kw="format|check"; cli="biome format / biome check"
fi
[ -z "$tool" ] && exit 0

dir="${cwd:-$PWD}"
uses_biome=0
while [ -n "$dir" ]; do
  if [ -f "$dir/biome.json" ] || [ -f "$dir/biome.jsonc" ]; then uses_biome=1; break; fi
  [ "$dir" = "/" ] && break
  dir=$(dirname "$dir")
done
[ "$uses_biome" -eq 0 ] && exit 0

pkg=""
dir="${cwd:-$PWD}"
while [ -n "$dir" ]; do
  if [ -f "$dir/package.json" ]; then pkg="$dir/package.json"; break; fi
  [ "$dir" = "/" ] && break
  dir=$(dirname "$dir")
done

pm="npm"
if [ -n "$pkg" ]; then
  field=$(jq -r '.packageManager // empty' "$pkg" 2>/dev/null)
  case "$field" in
    pnpm*) pm="pnpm" ;;
    yarn*) pm="yarn" ;;
    bun*)  pm="bun" ;;
    npm*)  pm="npm" ;;
    *)
      dir=$(dirname "$pkg")
      while [ -n "$dir" ]; do
        if [ -f "$dir/pnpm-lock.yaml" ]; then pm="pnpm"; break; fi
        if [ -f "$dir/yarn.lock" ]; then pm="yarn"; break; fi
        if [ -f "$dir/bun.lockb" ] || [ -f "$dir/bun.lock" ]; then pm="bun"; break; fi
        if [ -f "$dir/package-lock.json" ]; then pm="npm"; break; fi
        [ "$dir" = "/" ] && break
        dir=$(dirname "$dir")
      done ;;
  esac
fi

# Pull this repo's own Biome-invoking scripts from package.json, preferring the ones whose
# name matches the relevant verb (lint/check for ESLint, format/check for Prettier).
scripts=""
if [ -n "$pkg" ]; then
  scripts=$(jq -r --arg kw "$kw" --arg pm "$pm" '
    (.scripts // {}) | to_entries
    | map(select(.value | test("biome"; "i"))) as $b
    | ($b | map(select(.key | test($kw; "i")))) as $p
    | (if ($p | length) > 0 then $p else $b end)
    | map($pm + " run " + .key)
    | join(" | ")
  ' "$pkg" 2>/dev/null)
fi

if [ -n "$scripts" ]; then
  reason="This repo uses Biome (biome.json present), not ${tool}. Use one of this repo's scripts instead: ${scripts} (or run ${cli} directly)."
else
  reason="This repo uses Biome (biome.json present), not ${tool}. Use ${cli} instead."
fi

jq -n --arg r "$reason" '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$r}}'
exit 0
