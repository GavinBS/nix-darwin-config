_pm_init() {
  local pm_state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/pm"
  local pm_projects_file="$pm_state_dir/projects"

  command mkdir -p -- "$pm_state_dir" || {
    print -u2 -r -- "pm: cannot create state directory"
    return 1
  }
  [[ -e "$pm_projects_file" ]] || : >| "$pm_projects_file" || {
    print -u2 -r -- "pm: cannot create projects file"
    return 1
  }
  [[ -f "$pm_projects_file" ]] || {
    print -u2 -r -- "pm: projects path is not a regular file"
    return 1
  }
  command chmod 700 "$pm_state_dir" && command chmod 600 "$pm_projects_file" || {
    print -u2 -r -- "pm: cannot secure state permissions"
    return 1
  }

  reply=("$pm_state_dir" "$pm_projects_file")
}

_pm_read_projects() {
  local file="$1" line
  reply=()

  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"
    [[ -n "$line" ]] && reply+=("$line")
  done < "$file"
}

_pm_select() {
  local file="$1" query="$2"
  local -a projects records
  local -A name_counts
  local project_path name parent display selected
  local i fzf_status

  command -v fzf >/dev/null 2>&1 || {
    print -u2 -r -- "pm: fzf is required"
    return 1
  }

  _pm_read_projects "$file" || return 1
  projects=("${reply[@]}")

  # Missing directories stay in the file until `pm clean`, but are omitted here.
  local -a existing
  for project_path in "${projects[@]}"; do
    [[ -d "$project_path" ]] && existing+=("$project_path")
  done
  projects=("${existing[@]}")

  if (( ${#projects} == 0 )); then
    print -r -- "pm: no available projects"
    return 0
  fi

  for project_path in "${projects[@]}"; do
    name="${project_path:t}"
    [[ -n "$name" ]] || name="$project_path"
    (( name_counts[$name]++ ))
  done

  for (( i = 1; i <= ${#projects}; i++ )); do
    project_path="${projects[$i]}"
    name="${project_path:t}"
    [[ -n "$name" ]] || name="$project_path"
    display="$name"
    if (( name_counts[$name] > 1 )); then
      parent="${project_path:h}"
      if [[ "$parent" == "$HOME" ]]; then
        parent="~"
      elif [[ "$parent" == "$HOME/"* ]]; then
        parent="~/${parent#"$HOME/"}"
      fi
      display="$name  [$parent]"
    fi
    records+=("$i"$'\t'"$display")
  done

  selected=$(printf '%s\n' "${records[@]}" | command fzf \
    --height=60% \
    --layout=reverse \
    --border \
    --prompt='Projects > ' \
    --delimiter=$'\t' \
    --with-nth=2.. \
    --query="$query")
  fzf_status=$?

  if (( fzf_status == 1 || fzf_status == 130 )); then
    return 0
  elif (( fzf_status != 0 )); then
    print -u2 -r -- "pm: fzf failed"
    return "$fzf_status"
  fi

  i="${selected%%$'\t'*}"
  [[ "$i" == <-> && -n "${projects[$i]-}" ]] || {
    print -u2 -r -- "pm: invalid selection"
    return 1
  }
  builtin cd -- "${projects[$i]}"
}

_pm_add() {
  local file="$1" input="${2:-.}" project_path existing

  if [[ "$input" == "~" ]]; then
    input="$HOME"
  elif [[ "$input" == '~/'* ]]; then
    input="$HOME/${input#'~/'}"
  fi

  [[ -e "$input" ]] || {
    print -u2 -r -- "pm: path does not exist: $input"
    return 1
  }
  [[ -d "$input" ]] || {
    print -u2 -r -- "pm: path is not a directory: $input"
    return 1
  }

  project_path="${input:A}"
  _pm_read_projects "$file" || return 1
  for existing in "${reply[@]}"; do
    if [[ "$existing" == "$project_path" ]]; then
      print -r -- "pm: project already exists"
      return 0
    fi
  done

  print -r -- "$project_path" >> "$file" || {
    print -u2 -r -- "pm: cannot update projects file"
    return 1
  }
  print -r -- "pm: project added"
}

_pm_remove() {
  local state_dir="$1" file="$2"
  local -a projects records
  local -A name_counts
  local project_path name parent display selected tmp
  local i fzf_status

  command -v fzf >/dev/null 2>&1 || {
    print -u2 -r -- "pm: fzf is required"
    return 1
  }
  _pm_read_projects "$file" || return 1
  projects=("${reply[@]}")
  if (( ${#projects} == 0 )); then
    print -r -- "pm: no projects"
    return 0
  fi

  for project_path in "${projects[@]}"; do
    name="${project_path:t}"
    [[ -n "$name" ]] || name="$project_path"
    (( name_counts[$name]++ ))
  done
  for (( i = 1; i <= ${#projects}; i++ )); do
    project_path="${projects[$i]}"
    name="${project_path:t}"
    [[ -n "$name" ]] || name="$project_path"
    display="$name"
    if (( name_counts[$name] > 1 )); then
      parent="${project_path:h}"
      [[ "$parent" == "$HOME" ]] && parent="~"
      [[ "$parent" == "$HOME/"* ]] && parent="~/${parent#"$HOME/"}"
      display="$name  [$parent]"
    fi
    records+=("$i"$'\t'"$display")
  done

  selected=$(printf '%s\n' "${records[@]}" | command fzf \
    --height=60% --layout=reverse --border \
    --prompt='Remove > ' --delimiter=$'\t' --with-nth=2..)
  fzf_status=$?
  if (( fzf_status == 1 || fzf_status == 130 )); then
    return 0
  elif (( fzf_status != 0 )); then
    print -u2 -r -- "pm: fzf failed"
    return "$fzf_status"
  fi

  i="${selected%%$'\t'*}"
  [[ "$i" == <-> && -n "${projects[$i]-}" ]] || {
    print -u2 -r -- "pm: invalid selection"
    return 1
  }

  tmp=$(command mktemp "$state_dir/projects.tmp.XXXXXX") || {
    print -u2 -r -- "pm: cannot create temporary file"
    return 1
  }
  : >| "$tmp" || { command rm -f -- "$tmp"; return 1; }
  local j
  for (( j = 1; j <= ${#projects}; j++ )); do
    (( j == i )) || print -r -- "${projects[$j]}" >> "$tmp" || {
      command rm -f -- "$tmp"
      print -u2 -r -- "pm: cannot update projects file"
      return 1
    }
  done
  command mv -f -- "$tmp" "$file" || {
    command rm -f -- "$tmp"
    print -u2 -r -- "pm: cannot replace projects file"
    return 1
  }
  print -r -- "pm: project removed"
}

_pm_list() {
  local file="$1" project_path name
  _pm_read_projects "$file" || return 1
  if (( ${#reply} == 0 )); then
    print -r -- "pm: no projects"
    return 0
  fi
  for project_path in "${reply[@]}"; do
    name="${project_path:t}"
    [[ -n "$name" ]] || name="$project_path"
    printf '%-24s %s\n' "$name" "$project_path"
  done
}

_pm_clean() {
  local state_dir="$1" file="$2" tmp project_path
  local -a projects
  local removed=0

  _pm_read_projects "$file" || return 1
  projects=("${reply[@]}")
  tmp=$(command mktemp "$state_dir/projects.tmp.XXXXXX") || {
    print -u2 -r -- "pm: cannot create temporary file"
    return 1
  }
  : >| "$tmp" || { command rm -f -- "$tmp"; return 1; }
  for project_path in "${projects[@]}"; do
    if [[ -d "$project_path" ]]; then
      print -r -- "$project_path" >> "$tmp" || {
        command rm -f -- "$tmp"
        print -u2 -r -- "pm: cannot update projects file"
        return 1
      }
    else
      (( removed++ ))
    fi
  done
  command mv -f -- "$tmp" "$file" || {
    command rm -f -- "$tmp"
    print -u2 -r -- "pm: cannot replace projects file"
    return 1
  }
  if (( removed == 0 )); then
    print -r -- "pm: no missing projects"
  else
    print -r -- "pm: removed $removed missing project(s)"
  fi
}

_pm_help() {
  print -r -- 'Usage:
  pm [query]        Select and enter a project
  pm add [path]     Add current or specified directory
  pm remove         Remove a project
  pm list           List projects
  pm clean          Remove missing project paths
  pm edit           Edit project list
  pm help           Show help'
}

pm() {
  emulate -L zsh
  setopt localoptions no_aliases

  local -a state
  local command_name="${1-}" arg
  _pm_init || return 1
  state=("${reply[@]}")

  case "$command_name" in
    add)
      (( $# <= 2 )) || { print -u2 -r -- "pm: usage: pm add [path]"; return 2; }
      _pm_add "${state[2]}" "${2:-.}"
      ;;
    remove)
      (( $# == 1 )) || { print -u2 -r -- "pm: usage: pm remove"; return 2; }
      _pm_remove "${state[1]}" "${state[2]}"
      ;;
    list)
      (( $# == 1 )) || { print -u2 -r -- "pm: usage: pm list"; return 2; }
      _pm_list "${state[2]}"
      ;;
    clean)
      (( $# == 1 )) || { print -u2 -r -- "pm: usage: pm clean"; return 2; }
      _pm_clean "${state[1]}" "${state[2]}"
      ;;
    edit)
      (( $# == 1 )) || { print -u2 -r -- "pm: usage: pm edit"; return 2; }
      [[ -n "${EDITOR:-}" ]] || { print -u2 -r -- "pm: EDITOR is not set"; return 1; }
      command "$EDITOR" "${state[2]}"
      ;;
    help|-h|--help)
      (( $# == 1 )) || { print -u2 -r -- "pm: usage: pm help"; return 2; }
      _pm_help
      ;;
    '')
      _pm_select "${state[2]}" ''
      ;;
    *)
      _pm_select "${state[2]}" "$*"
      ;;
  esac
}
