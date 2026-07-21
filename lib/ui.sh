#!/usr/bin/env bash
# Interactive tool checklist. Operates on the parallel arrays populated by
# setup.sh (IDS, CATS, DESCS, DEFAULTS, INSTALLED) and sets SELECTED[i]=0|1.
#
# Dependency-free by design (a numbered toggle menu), so it works before any of
# the tools it installs are present.

# A tool is "locked" (skipped, not toggleable) only when it is installed and we
# are not in upgrade mode.
_omt_locked() { [ "${INSTALLED[$1]}" = 1 ] && [ "${UPGRADE:-0}" != 1 ]; }

# Initialize SELECTED: core tier pre-checked, opt tier off, locked tools skipped.
ui_init_selection() {
  local i
  for i in "${!IDS[@]}"; do
    if _omt_locked "$i"; then
      SELECTED[$i]=0
    elif [ "${DEFAULTS[$i]}" = core ]; then
      SELECTED[$i]=1
    else
      SELECTED[$i]=0
    fi
  done
}

_ui_marker() {  # index -> "[x]" | "[ ]" | "[installed]"
  local i=$1
  if _omt_locked "$i"; then printf '%s[installed]%s' "$C_DIM" "$C_RESET"
  elif [ "${SELECTED[$i]}" = 1 ]; then printf '%s[x]%s' "$C_GREEN$C_BOLD" "$C_RESET"
  else printf '[ ]'
  fi
}

ui_render() {
  local i cat last_cat=""
  printf '\n%sSelect tools to install%s  (%score%s = recommended defaults)\n' \
    "$C_BOLD" "$C_RESET" "$C_GREEN" "$C_RESET"
  [ "${UPGRADE:-0}" = 1 ] && printf '%supgrade mode: installed tools can be reselected to reinstall the latest%s\n' "$C_YELLOW" "$C_RESET"
  printf '%s----------------------------------------------------------------%s\n' "$C_DIM" "$C_RESET"
  for i in "${!IDS[@]}"; do
    cat="${CATS[$i]}"
    if [ "$cat" != "$last_cat" ]; then
      printf '\n%s%s%s\n' "$C_BLUE$C_BOLD" "$cat" "$C_RESET"
      last_cat="$cat"
    fi
    printf '  %2d. %-12s %-24s %s%s%s\n' \
      "$((i + 1))" "$(_ui_marker "$i")" "${IDS[$i]}" "$C_DIM" "${DESCS[$i]}" "$C_RESET"
  done
  printf '\n%sCommands:%s  <numbers/ranges> toggle (e.g. 3 7-9)   a all   n none   c core   Enter accept   q quit\n' \
    "$C_BOLD" "$C_RESET"
}

_ui_toggle() {  # index (1-based); no-op on installed items
  local n=$1
  local i=$((n - 1))
  if [ "$i" -lt 0 ] || [ "$i" -ge "${#IDS[@]}" ]; then
    warn "ignoring out-of-range number: $n"; return
  fi
  if _omt_locked "$i"; then
    warn "${IDS[$i]} is already installed (use --upgrade to reinstall)"; return
  fi
  if [ "${SELECTED[$i]}" = 1 ]; then SELECTED[$i]=0; else SELECTED[$i]=1; fi
}

_ui_set_all() {  # value: 1 selects every selectable tool, 0 clears
  local i val=$1
  for i in "${!IDS[@]}"; do
    _omt_locked "$i" && { SELECTED[$i]=0; continue; }
    SELECTED[$i]=$val
  done
}

_ui_set_core() {
  local i
  for i in "${!IDS[@]}"; do
    if _omt_locked "$i"; then SELECTED[$i]=0
    elif [ "${DEFAULTS[$i]}" = core ]; then SELECTED[$i]=1
    else SELECTED[$i]=0; fi
  done
}

# Main entry: mutate SELECTED interactively until the user accepts.
ui_select_tools() {
  ui_init_selection
  local line tok lo hi n tmp
  while true; do
    ui_render
    printf '\n> '
    read -r line || { line=q; }
    case "$line" in
      "")  return 0 ;;                       # accept
      q|Q) return 130 ;;                      # abort
      a|A) _ui_set_all 1 ;;
      n|N) _ui_set_all 0 ;;
      c|C) _ui_set_core ;;
      *)
        for tok in $line; do
          if [[ "$tok" =~ ^[0-9]+-[0-9]+$ ]]; then
            lo="${tok%-*}"; hi="${tok#*-}"
            [ "$lo" -le "$hi" ] || { tmp=$lo; lo=$hi; hi=$tmp; }
            for ((n = lo; n <= hi; n++)); do _ui_toggle "$n"; done
          elif [[ "$tok" =~ ^[0-9]+$ ]]; then
            _ui_toggle "$tok"
          else
            warn "unrecognized input: $tok"
          fi
        done
        ;;
    esac
  done
}
