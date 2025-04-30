typeset -a fzf_default_colors=(
  "border:#dfdad9"
  "header:#286983"
  "info:#56949f"
  "gutter:#faf4ed"
  "prompt:#797593"
  "pointer:#907aa9"
  "marker:#b4637a"
  "spinner:#ea9d34"
  "fg:#797593"
  "fg+:#575279"
  "bg:#faf4ed"
  "bg+:#f2e9e1"
  "hl:#d7827e"
  "hl+:#d7827e"
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
