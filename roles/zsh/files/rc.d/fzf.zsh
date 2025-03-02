typeset -a fzf_default_colors=(
  "info:33"
  "prompt:33"
  "pointer:166"
  "marker:166"
  "spinner:33"
  "fg:240"
  "fg+:241"
  "bg+:255"
  "hl:33"
  "hl+:33:bold"
)

typeset -a fzf_default_opts=(
  "--color=${(j',')fzf_default_colors}"
  "--info=inline"
  "--select-1"
  "--exit-0"
  "--reverse"
  "--height=~100%"
)

typeset -a eza_opts=(
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

export FZF_DEFAULT_OPTS="${(j' ')fzf_default_opts}"

zstyle ':fzf-tab:*' switch-group '<' '>'
zstyle ':fzf-tab:*' fzf-flags --color='light' --border='rounded' --height='~100%'
zstyle ':fzf-tab:complete:cd:*' fzf-preview "eza ${(j' ')eza_opts} $realpath"
