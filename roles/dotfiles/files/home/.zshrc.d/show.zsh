#!/usr/bin/env zsh

#
#
# Author: Brad Frank
# Date: March 2024
# Tested: zsh 5.9 (arm-apple-darwin22.1.0)
# Requires: bat, jq
#

show() {
  local arg opt_help opt_pager no_pager \
        whence_type whence_word orig_path real_path disp_path charset_regex
  local -a bat

  charset_regex="[0-9A-Za-z_:\-]+"

  zparseopts -D -E -- \
    h=opt_help  -help=opt_help \
    p=opt_pager -no-pager=opt_pager \

  [[ -n $opt_help ]] && { _show_usage; return 0; }
  [[ -n $opt_pager ]] && bat=("bat" "--paging=never") || bat=("bat" "--paging=always")
  [[ -z "$1" ]] && arg="$(fzf --no-multi -0 -1)" || arg="$1"

  whence_word="$(whence -w "$arg")"
  whence_type="${${(s/ /)whence_word}[2]}"

  case "$whence_type" in
    "alias")
      whence -f "$arg" | bat --pager=never --language=sh
      ;;
    "builtin")
      run-help "$arg"
      ;;
    "command")
      orig_path="$(whence "$arg")"
      real_path="$(realpath -- "$orig_path")"
      disp_path="%F{64}${real_path}%f"
      [[ "$orig_path" != "$real_path" ]] && disp_path="%F{136}${orig_path}%f  %F{64}${real_path}%f"
      source =(file --brief --mime "$real_path" | grep -Eo "charset=${charset_regex}" | sort -u)
      [[ "$charset" == "binary" ]] && print -P -- "$disp_path" || "${bat[@]}" "$real_path"
      ;;
    "function")
      whence -f "$arg" | "${bat[@]}" --language=sh
      ;;
    "hashed")
      print -P -- "$whence_word"
      ;;
    "reserved")
      print -P -- "$whence_word"
      ;;
    "none")
      case "${arg:t:e}" in
        "md") PAGER="${bat[@]}" glow "$arg" ;;
        "json") jq -C < "$arg" | "${bat[@]}" ;;
        *) "${bat[@]}" "$arg" ;;
      esac
      ;;
  esac
}
