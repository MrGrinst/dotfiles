jj_is_protected_bookmark() {
  case "${1:-}" in
    dev | main | master) return 0 ;;
    *) return 1 ;;
  esac
}

jj_validate_share_bookmark() {
  local name="${1:-}"

  if [[ -z "$name" ]]; then
    echo "Bookmark name cannot be blank." >&2
    return 1
  fi

  if jj_is_protected_bookmark "$name"; then
    echo "'$name' is a protected trunk bookmark and will never be moved by these helpers." >&2
    return 1
  fi
}

jj_require_repo() {
  if ! command -v jj >/dev/null 2>&1; then
    echo "jj is not installed. Install it first." >&2
    return 1
  fi

  if ! jj st --color=never >/dev/null 2>&1; then
    echo "Not in a jj repository." >&2
    return 1
  fi
}

jj_has_local_bookmark() {
  local name="$1"
  local output

  output="$(jj bookmark list "$name" --all-remotes --color=never -T 'if(remote, "", name ++ "\n")' 2>/dev/null || true)"
  [[ "$output" == *"$name"* ]]
}

jj_has_exact_local_bookmark() {
  local name="$1"

  jj bookmark list "$name" --all-remotes --ignore-working-copy --color=never \
    -T 'if(remote, "", name ++ "\n")' 2>/dev/null \
    | grep -qxF "$name"
}

jj_has_origin_bookmark() {
  local name="$1"
  jj bookmark list --remote origin --ignore-working-copy --color=never \
    -T 'if(remote == "origin", name ++ "\n", "")' 2>/dev/null \
    | grep -qxF "$name"
}

jj_list_local_bookmarks_on_revset() {
  local revset="${1:-@-}"

  jj log -r "$revset" --no-graph -T 'local_bookmarks.map(|b| b.name()).join("\n")' --color=never 2>/dev/null \
    | sed '/^$/d'
}

jj_filter_non_protected_bookmarks() {
  while IFS= read -r bookmark || [[ -n "$bookmark" ]]; do
    [[ -n "$bookmark" ]] || continue
    if ! jj_is_protected_bookmark "$bookmark"; then
      printf '%s\n' "$bookmark"
    fi
  done

  return 0
}

jj_unique_lines() {
  awk 'NF && !seen[$0]++'
}

jj_resolve_share_bookmark_on_current_change() {
  local explicit_bookmark="${1:-}"
  local all_bookmarks
  local share_bookmarks
  local share_count
  local all_count

  if [[ -n "$explicit_bookmark" ]]; then
    jj_validate_share_bookmark "$explicit_bookmark" || return 1
    printf '%s\n' "$explicit_bookmark"
    return 0
  fi

  all_bookmarks="$(jj_list_local_bookmarks_on_revset '@-' | jj_unique_lines)"
  share_bookmarks="$(printf '%s\n' "$all_bookmarks" | jj_filter_non_protected_bookmarks | jj_unique_lines)"
  share_count="$(printf '%s\n' "$share_bookmarks" | sed '/^$/d' | wc -l | tr -d ' ')"
  all_count="$(printf '%s\n' "$all_bookmarks" | sed '/^$/d' | wc -l | tr -d ' ')"

  if [[ "$share_count" == "1" ]]; then
    printf '%s\n' "$share_bookmarks"
    return 0
  fi

  if [[ "$share_count" == "0" ]]; then
    if [[ "$all_count" == "0" ]]; then
      echo "No bookmark points at @-. Run 'jbm <feature-bookmark>' or pass one explicitly." >&2
    else
      echo "Only protected trunk bookmarks point at @-. Run 'jbm <feature-bookmark>' or pass one explicitly." >&2
    fi
    return 1
  fi

  echo "Multiple non-trunk bookmarks point at @-. Pass one explicitly." >&2
  return 1
}

jj_set_share_bookmark_on_current_change() {
  local bookmark="$1"

  jj_validate_share_bookmark "$bookmark" || return 1
  jj bookmark set "$bookmark" -r @-
}

jj_advance_share_bookmark_to_current_change() {
  local bookmark="$1"

  jj_validate_share_bookmark "$bookmark" || return 1
  jj bookmark advance "$bookmark" --to @-
}

jj_resolve_pr_base_bookmark() {
  local pushed_bookmark="$1"
  local parent_bookmarks
  local candidate_bookmarks
  local protected_candidates
  local candidate_count
  local protected_count

  parent_bookmarks="$(jj_list_local_bookmarks_on_revset 'parents(@-)' | jj_unique_lines)"
  candidate_bookmarks="$(
    while IFS= read -r bookmark; do
      [[ -n "$bookmark" ]] || continue
      [[ "$bookmark" == "$pushed_bookmark" ]] && continue
      printf '%s\n' "$bookmark"
    done <<<"$parent_bookmarks" | jj_unique_lines
  )"
  protected_candidates="$(printf '%s\n' "$candidate_bookmarks" | while IFS= read -r bookmark; do
    [[ -n "$bookmark" ]] || continue
    if jj_is_protected_bookmark "$bookmark"; then
      printf '%s\n' "$bookmark"
    fi
  done | jj_unique_lines)"
  candidate_count="$(printf '%s\n' "$candidate_bookmarks" | sed '/^$/d' | wc -l | tr -d ' ')"
  protected_count="$(printf '%s\n' "$protected_candidates" | sed '/^$/d' | wc -l | tr -d ' ')"

  if [[ "$protected_count" == "1" ]]; then
    printf '%s\n' "$protected_candidates"
    return 0
  fi

  if [[ "$candidate_count" == "1" ]]; then
    printf '%s\n' "$candidate_bookmarks"
    return 0
  fi

  echo "Could not determine a unique PR base from parent bookmarks. Pass one explicitly: jph <bookmark> <base>" >&2
  return 1
}

jj_base_bookmark() {
  jj_require_repo

  local candidate
  for candidate in dev main master; do
    if jj_has_local_bookmark "$candidate"; then
      printf '%s\n' "$candidate"
      return 0
    fi

    if jj_has_origin_bookmark "$candidate"; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done

  echo "Could not find a base bookmark. Expected one of: dev, main, master." >&2
  return 1
}

jj_has_any_remote_bookmark() {
  local name="$1"
  local output

  output="$(jj bookmark list "$name" --all-remotes --ignore-working-copy --color=never 2>/dev/null || true)"

  awk '
    /^[[:space:]]+@[^[:space:]]+:/ {
      found = 1
      exit
    }
    END { exit(found ? 0 : 1) }
  ' <<<"$output"
}

jj_list_workspace_names() {
  jj workspace list --color=never 2>/dev/null | sed -E 's/:.*$//'
}

jj_workspace_name_exists() {
  local name="$1"

  jj_list_workspace_names | grep -qxF "$name"
}

jj_current_workspace_name() {
  local current_commit
  local workspace_list

  current_commit="$(jj log -r @ --no-graph -T 'commit_id.shortest(8)' --color=never 2>/dev/null | tr -d '\n')"
  [[ -n "$current_commit" ]] || return 1

  workspace_list="$(jj workspace list --color=never 2>/dev/null)" || return 1

  awk -v commit="$current_commit" '$3 == commit { sub(/:.*/, "", $1); print $1; exit }' <<<"$workspace_list"
}

jjf_workspace_root() {
  local root="${JJF_WORKSPACE_ROOT:-${HOME}/workspaces/jj}"

  if [[ -d "$root" ]]; then
    (
      cd "$root"
      pwd -P
    )
    return 0
  fi

  printf '%s\n' "$root"
}

jjf_registry_path() {
  printf '%s/.jjf-registry.tsv\n' "$(jjf_workspace_root)"
}

jjf_registry_lookup() {
  local repo_name="$1"
  local alias_name="$2"
  local registry_path
  local entry_repo
  local entry_alias
  local entry_path

  registry_path="$(jjf_registry_path)"
  [[ -f "$registry_path" ]] || return 1

  while IFS=$'\t' read -r entry_repo entry_alias entry_path; do
    [[ -n "$entry_repo" && -n "$entry_alias" && -n "$entry_path" ]] || continue
    [[ "$entry_repo" == "$repo_name" && "$entry_alias" == "$alias_name" ]] || continue
    [[ -d "$entry_path" ]] || continue
    printf '%s\n' "$entry_path"
    return 0
  done <"$registry_path"

  return 1
}

jjf_registry_write() {
  local registry_path="$1"
  local tmp_path="$2"

  if [[ -s "$tmp_path" ]]; then
    mv "$tmp_path" "$registry_path"
  else
    rm -f "$tmp_path"
    rm -f "$registry_path"
  fi
}

jjf_registry_set() {
  local repo_name="$1"
  local alias_name="$2"
  local workspace_path="$3"
  local registry_path
  local tmp_path
  local entry_repo
  local entry_alias
  local entry_path

  [[ -n "$repo_name" && -n "$alias_name" && -n "$workspace_path" ]] || return 1

  mkdir -p "$(jjf_workspace_root)"
  registry_path="$(jjf_registry_path)"
  tmp_path="$(mktemp "${registry_path}.XXXXXX")"

  if [[ -f "$registry_path" ]]; then
    while IFS=$'\t' read -r entry_repo entry_alias entry_path; do
      [[ -n "$entry_repo" && -n "$entry_alias" && -n "$entry_path" ]] || continue
      [[ "$entry_repo" == "$repo_name" && "$entry_alias" == "$alias_name" ]] && continue
      printf '%s\t%s\t%s\n' "$entry_repo" "$entry_alias" "$entry_path" >>"$tmp_path"
    done <"$registry_path"
  fi

  printf '%s\t%s\t%s\n' "$repo_name" "$alias_name" "$workspace_path" >>"$tmp_path"
  jjf_registry_write "$registry_path" "$tmp_path"
}

jjf_registry_remove() {
  local repo_name="$1"
  local alias_name="$2"
  local registry_path
  local tmp_path
  local entry_repo
  local entry_alias
  local entry_path

  registry_path="$(jjf_registry_path)"
  [[ -f "$registry_path" ]] || return 0

  tmp_path="$(mktemp "${registry_path}.XXXXXX")"
  while IFS=$'\t' read -r entry_repo entry_alias entry_path; do
    [[ -n "$entry_repo" && -n "$entry_alias" && -n "$entry_path" ]] || continue
    [[ "$entry_repo" == "$repo_name" && "$entry_alias" == "$alias_name" ]] && continue
    printf '%s\t%s\t%s\n' "$entry_repo" "$entry_alias" "$entry_path" >>"$tmp_path"
  done <"$registry_path"

  jjf_registry_write "$registry_path" "$tmp_path"
}

jjf_slugify() {
  printf '%s' "$1" |
    tr '[:upper:]' '[:lower:]' |
    sed -E 's#[[:space:]_]+#-#g' |
    sed -E 's#[^a-z0-9./-]#-#g' |
    sed -E 's#[./]+#-#g' |
    sed -E 's#-+#-#g' |
    sed -E 's#^-+|-+$##g'
}

jjf_workspace_path_for_slug() {
  local repo_name="$1"
  local slug="$2"
  printf '%s/%s--%s\n' "$(jjf_workspace_root)" "$repo_name" "$slug"
}

jjf_resolve_unique_target_for_repo_name() {
  local repo_name="$1"
  local requested_name="$2"
  local ignored_bookmark="${3:-}"
  local ignored_workspace="${4:-}"
  local ignored_path="${5:-}"
  local base_slug
  local candidate_slug
  local candidate_bookmark
  local candidate_workspace
  local candidate_path
  local suffix=1

  base_slug="$(jjf_slugify "$requested_name")"
  [[ -n "$base_slug" ]] || {
    echo "Name '$requested_name' produced an empty workspace slug." >&2
    return 1
  }

  while :; do
    if [[ "$suffix" -eq 1 ]]; then
      candidate_slug="$base_slug"
    else
      candidate_slug="${base_slug}-${suffix}"
    fi

    candidate_bookmark="$candidate_slug"
    candidate_workspace="$candidate_slug"
    candidate_path="$(jjf_workspace_path_for_slug "$repo_name" "$candidate_slug")"

    if [[ -e "$candidate_path" && "$candidate_path" != "$ignored_path" ]]; then
      suffix=$((suffix + 1))
      continue
    fi

    if [[ "$candidate_bookmark" != "$ignored_bookmark" ]] && {
      jj_has_local_bookmark "$candidate_bookmark" || jj_has_any_remote_bookmark "$candidate_bookmark"
    }; then
      suffix=$((suffix + 1))
      continue
    fi

    if [[ "$candidate_workspace" != "$ignored_workspace" ]] && jj_workspace_name_exists "$candidate_workspace"; then
      suffix=$((suffix + 1))
      continue
    fi

    printf '%s\t%s\t%s\n' "$candidate_bookmark" "$candidate_workspace" "$candidate_path"
    return 0
  done
}

jjf_resolve_unique_logical_target_for_repo_name() {
  local requested_name="$1"
  local ignored_bookmark="${2:-}"
  local ignored_workspace="${3:-}"
  local base_slug
  local candidate_slug
  local candidate_bookmark
  local candidate_workspace
  local suffix=1

  base_slug="$(jjf_slugify "$requested_name")"
  [[ -n "$base_slug" ]] || {
    echo "Name '$requested_name' produced an empty workspace slug." >&2
    return 1
  }

  while :; do
    if [[ "$suffix" -eq 1 ]]; then
      candidate_slug="$base_slug"
    else
      candidate_slug="${base_slug}-${suffix}"
    fi

    candidate_bookmark="$candidate_slug"
    candidate_workspace="$candidate_slug"

    if [[ "$candidate_bookmark" != "$ignored_bookmark" ]] && {
      jj_has_local_bookmark "$candidate_bookmark" || jj_has_any_remote_bookmark "$candidate_bookmark"
    }; then
      suffix=$((suffix + 1))
      continue
    fi

    if [[ "$candidate_workspace" != "$ignored_workspace" ]] && jj_workspace_name_exists "$candidate_workspace"; then
      suffix=$((suffix + 1))
      continue
    fi

    printf '%s\t%s\n' "$candidate_bookmark" "$candidate_workspace"
    return 0
  done
}

jjf_resolve_unique_target() {
  local repo_root="$1"
  local requested_name="$2"
  local ignored_bookmark="${3:-}"
  local ignored_workspace="${4:-}"
  local ignored_path="${5:-}"

  jjf_resolve_unique_target_for_repo_name "$(basename "$repo_root")" "$requested_name" "$ignored_bookmark" "$ignored_workspace" "$ignored_path"
}

jjf_find_exact_origin_bookmark() {
  local repo_root="$1"
  local requested_name="$2"

  (
    cd "$repo_root" &&
      if jj_has_origin_bookmark "$requested_name"; then
        printf '%s\n' "$requested_name"
      fi
  )
}

jjf_find_exact_bookmark() {
  local repo_root="$1"
  local requested_name="$2"

  (
    cd "$repo_root" || exit 1

    if jj_has_exact_local_bookmark "$requested_name"; then
      printf '%s\t%s\n' "$requested_name" "$requested_name"
      exit 0
    fi

    if jj_has_origin_bookmark "$requested_name"; then
      printf '%s\t%s\n' "$requested_name" "${requested_name}@origin"
      exit 0
    fi
  )
}

jjf_resolve_existing_bookmark_target_for_repo_name() {
  local repo_name="$1"
  local bookmark_name="$2"
  local requested_name="${3:-$bookmark_name}"
  local ignored_workspace="${4:-}"
  local ignored_path="${5:-}"
  local base_slug
  local candidate_slug
  local candidate_workspace
  local candidate_path
  local suffix=1

  base_slug="$(jjf_slugify "$requested_name")"
  [[ -n "$base_slug" ]] || base_slug="$(jjf_slugify "$bookmark_name")"
  [[ -n "$base_slug" ]] || {
    echo "Name '$requested_name' produced an empty workspace slug." >&2
    return 1
  }

  while :; do
    if [[ "$suffix" -eq 1 ]]; then
      candidate_slug="$base_slug"
    else
      candidate_slug="${base_slug}-${suffix}"
    fi

    candidate_workspace="$candidate_slug"
    candidate_path="$(jjf_workspace_path_for_slug "$repo_name" "$candidate_slug")"

    if [[ -e "$candidate_path" && "$candidate_path" != "$ignored_path" ]]; then
      suffix=$((suffix + 1))
      continue
    fi

    if [[ "$candidate_workspace" != "$ignored_workspace" ]] && jj_workspace_name_exists "$candidate_workspace"; then
      suffix=$((suffix + 1))
      continue
    fi

    printf '%s\t%s\t%s\n' "$bookmark_name" "$candidate_workspace" "$candidate_path"
    return 0
  done
}

jjf_resolve_existing_bookmark_target() {
  local repo_root="$1"
  local bookmark_name="$2"
  local requested_name="${3:-$bookmark_name}"
  local ignored_workspace="${4:-}"
  local ignored_path="${5:-}"

  jjf_resolve_existing_bookmark_target_for_repo_name "$(basename "$repo_root")" "$bookmark_name" "$requested_name" "$ignored_workspace" "$ignored_path"
}

jjf_workspace_session_name() {
  local repo_name="$1"
  local workspace_name="$2"

  printf '%s--%s\n' "$repo_name" "$workspace_name"
}

jjf_repo_name_from_workspace_path() {
  local workspace_path="$1"
  local workspace_name="$2"
  local workspace_basename
  local suffix

  workspace_basename="$(basename "$workspace_path")"
  suffix="--${workspace_name}"

  if [[ "$workspace_basename" == *"$suffix" ]]; then
    printf '%s\n' "${workspace_basename%"$suffix"}"
    return 0
  fi

  printf '%s\n' "$workspace_basename"
}

jj_resolve_workspace_share_bookmark() {
  local bookmark
  local count
  local revset

  for revset in @ @-; do
    bookmark="$(jj_list_local_bookmarks_on_revset "$revset" | jj_filter_non_protected_bookmarks | jj_unique_lines)"
    count="$(printf '%s\n' "$bookmark" | sed '/^$/d' | wc -l | tr -d ' ')"

    if [[ "$count" == "1" ]]; then
      printf '%s\n' "$bookmark"
      return 0
    fi

    if [[ "$count" != "0" ]]; then
      echo "Multiple non-trunk bookmarks point at $revset. Clean that up before renaming." >&2
      return 1
    fi
  done

  echo "No non-trunk bookmark points at @ or @-. Create one first or start from jjf." >&2
  return 1
}
