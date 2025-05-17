typeset -a __eza_opts=(
  "--almost-all"
  "--long"
  "--octal-permissions"
  "--group-directories-first"
  "--color=always"
  "--smart-group"
  "--no-permissions"
  "--no-filesize"
  "--time-style=relative"
)

export FZF_DEFAULT_OPTS_FILE="${HOME}/.config/fzf/config"

zstyle ':fzf-tab:*' switch-group '<' '>'
zstyle ':fzf-tab:complete:cd:*' fzf-preview "eza ${(j' ')__eza_opts} $realpath"
