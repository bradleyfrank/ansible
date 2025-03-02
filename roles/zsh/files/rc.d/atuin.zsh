#!/usr/bin/env zsh

last-command() {
  atuin history last --cmd-only
}

copy-last-command() {
  local last_command
  if last_command="$(last-command)"; then
    print -P -- "Copied: %F{64}${last_command}%f"
    case "$(uname --kernel-name)" in
      Darwin) pbcopy  <<< "$last_command" ;;
       Linux) wl-copy <<< "$last_command" ;;
      esac
  else
    print -P -- "%F{160}Could not copy previous command%f"
  fi
}

alias lc="last-command"
alias clc="copy-last-command"
