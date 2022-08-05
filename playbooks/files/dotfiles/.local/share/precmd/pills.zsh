precmd() {
  typeset    rc=$? k8s_cxt
  typeset -a vcsinfo git_subdirectories
  typeset -A ps1
  typeset -r eol=$'\n' \
             icon_leftcap=$'\ue0b6' \
             icon_rightcap=$'\ue0b4' \
             icon_prompt=$'\uf054' \
             icon_folder=$'\uf74a' \
             icon_location=$'\uf124' \
             icon_git_branch=$'\ue725' \
             icon_host=$'\uf878' \
             icon_python=$'\ue606' \
             icon_k8s=$'\ufd31'
  typeset -r base0="244" \
             blue="33" \
             cyan="37" \
             green="64" \
             magenta="125" \
             orange="166" \
             red="160" \
             violet="61" \
             yellow="136"

  build_segment() {
    print -P -- "%B%F{${2}}${icon_leftcap}%f%K{${2}}%F{231}${1}%f%k%F{${2}}${icon_rightcap}%f%b"
  }

  ps1=([host]="" [cwd]="" [k8s]="" [pyenv]="" [git]="" [prompt]="")

  if [[ -n $SSH_CONNECTION && -z $TMUX ]]; then
    case $(uname -s) in Darwin) icon_host=$'\ue711' ;; Linux) icon_host=$'\uf30a' ;; esac
    ps1[host]="$(build_segment "${icon_host} %m" "${magenta}") "
  fi

  ps1[cwd]="$(build_segment "${icon_location} %1~" "${base0}") "

  if k8s_cxt="$(kubectl config current-context 2> /dev/null)"; then
    [[ $k8s_cxt =~ ^gke ]] && k8s_cxt="${k8s_cxt##*_}"
    ps1[k8s]="$(build_segment "${icon_k8s} ${k8s_cxt}" "${violet}") "
  fi

  if [[ -n "$VIRTUAL_ENV" ]]; then
    ps1[pyenv]="$(build_segment "${icon_python} $(python --version | grep -Po '3(\.\d+)')" "${cyan}") "
  fi

  zstyle ':vcs_info:git*' actionformats "%S %b %u%c %a"
  zstyle ':vcs_info:git*' check-for-changes true
  zstyle ':vcs_info:git*' formats "%S %b %u%c"
  zstyle ':vcs_info:git*' stagedstr "+"
  zstyle ':vcs_info:git*' unstagedstr "*"
  zstyle ':vcs_info:git*+set-message:*' hooks extended-git

  vcs_info

  if [[ -n $vcs_info_msg_0_ ]]; then
    vcsinfo=("${(@s| |)vcs_info_msg_0_}")  # [1] subdirectory [2] branch [3] status [4] action
    git_subdirectories=("${(@s|/|)vcsinfo[1]}")

    if [[ "${vcsinfo[1]}" == "." ]]; then
      git_depth="0"
    else
      git_depth="${#git_subdirectories}"
    fi

    if [[ $git_depth -ge 0 ]]; then
      ps1[git]+="$(build_segment "${icon_folder} ${git_depth}" "${yellow}") "
    fi

    if [[ -n ${vcsinfo[2]} ]]; then
      ps1[git]+="$(build_segment "${icon_git_branch} ${vcsinfo[2]}" "${green}")"
    fi

    if [[ -n ${vcsinfo[3]} ]]; then
      ps1[git]+=" $(build_segment "${vcsinfo[3]}" "${yellow}")"
    fi

    if [[ -n ${vcsinfo[4]} ]]; then
      ps1[git]+=" $(build_segment "${vcsinfo[4]}" "${red}")"
    fi
  fi

  case "$rc" in
    0) ps1[prompt]="%B%F{${green}}%#%f%b "   ;;
    1) ps1[prompt]="%B%F{${red}}%#%f%b "     ;;
    *) ps1[prompt]="%B%F{${magenta}}%#%f%b " ;;
  esac

  PROMPT="${eol}${icon_prompt} ${ps1[host]}${ps1[cwd]}${ps1[k8s]}${ps1[pyenv]}${ps1[git]}${eol}${ps1[prompt]}"
}

+vi-extended-git() {
  if [[ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" == "true" ]]; then
    if [[ -s $(git rev-parse --show-toplevel)/.git/refs/stash ]]; then hook_com[staged]+="$"; fi
    if git status --porcelain | grep -q "^?? " 2> /dev/null; then hook_com[staged]+="?"; fi
  fi
}
