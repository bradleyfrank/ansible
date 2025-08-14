precmd() {
  local    _rc=$? prompt_color
  local -a prompt_order
  local -A prompt_segments git_info
  local -r reset="%b%f%k" \
           bold="%B" \
           fg_red="%F{1}" \
           fg_green="%F{2}" \
           fg_yellow="%F{3}" \
           fg_blue="%F{4}" \
           fg_magenta="%F{5}" \
           fg_cyan="%F{6}" \
           fg_white="%F{7}" \
           fg_base03="%F{8}" \
           fg_orange="%F{9}" \
           fg_base01="%F{10}" \
           fg_violet="%F{13}" \
           bg_white="%K{7}"
  local -r segment_left="${fg_white}${reset}${bg_white}" \
           segment_right="${reset}${fg_white}${reset}"

  prompt_order=(
    newline
    lbrak
    host
    venv
    cwd
    git_branch
    git_status
    git_stash
    git_action
    rbrak
    newline
    prompt
  )

  prompt_segments=(
    [lbrak]="${bold}${fg_base03}[${reset}"
    [host]=""
    [venv]=""
    [cwd]=""
    [git_branch]=""
    [git_status]=""
    [git_stash]=""
    [git_action]=""
    [rbrak]="${bold}${fg_base03}]${reset}"
    [newline]=$'\n'
    [prompt]=""
  )

  vcs_info

  if [[ -n $SSH_CONNECTION && -z $TMUX ]]; then
    prompt_segments[host]="${fg_base03}@${reset}${fg_magenta}%m${reset}"
  fi

  if [[ -n $VIRTUAL_ENV ]]; then
    prompt_segments[venv]="(${fg_cyan}$(python --version | grep -Po '\d+\.\d+')${reset}) "
  fi

  if [[ -z $vcs_info_msg_0_ ]]; then
    prompt_segments[cwd]="${fg_blue}%1~${reset}"
  else
    while IFS='=' read -r key value; do
        git_info[$key]=$value
    done <<< $vcs_info_msg_0_

    #
    # cwd
    #
    # If the repo name matches the repo branch, this is a worktree; use the directory above the
    # git root directory as the project name. Otherwise it's not a worktree, so use the git root
    # directory as the project name.
    #
    if [[ "${git_info[repo]}" == "${git_info[branch]}" ]]; then
      prompt_segments[cwd]+="${segment_left}"
      prompt_segments[cwd]+="${fg_violet}${"$(git rev-parse --show-toplevel)":h:t}${reset}"
      prompt_segments[cwd]+="${segment_right}"
    else
      prompt_segments[cwd]+="${segment_left}"
      prompt_segments[cwd]+="${fg_violet}${"$(git rev-parse --show-toplevel)":t}${reset}"
      prompt_segments[cwd]+="${segment_right}"
    fi

    #
    # git_branch
    #
    # If the CWD is at least one directory below the repository root (i.e. not in the root
    # itself), break the PWD into an array, and reassemble it using just the first character
    # of each directory (i.e. Fish style).
    #
    prompt_segments[git_branch]+=" "
    prompt_segments[git_branch]+="${segment_left}"
    prompt_segments[git_branch]+="${fg_green}${git_info[branch]}"

    if [[ "${git_info[subdir]}" != "." ]]; then
      local i subdirs numdirs subpath=""
      subdirs=( ${(@s:/:)git_info[subdir]} )
      numdirs=$(( ${#subdirs} - 1 ))  # compensate for the leading slash
      if [[ $numdirs -ge 1 ]]; then
        for i in {1..${numdirs}}; do
          subpath+="/${subdirs[i][1]}"
        done
      fi
      prompt_segments[git_branch]+="${fg_base01}${subpath}/${subdirs[-1]}"
    fi

    prompt_segments[git_branch]+="${segment_right}"

    #
    # git_status
    #
    if [[ -n ${git_info[staged]} || -n ${git_info[unstaged]} ]]; then
      prompt_segments[git_status]+=" "
      prompt_segments[git_status]+="${segment_left}"
      prompt_segments[git_status]+="${fg_yellow}${git_info[staged]}"
      prompt_segments[git_status]+="${fg_yellow}${git_info[unstaged]}"
      prompt_segments[git_status]+="${segment_right}"
    fi

    #
    # git_stash
    #
    git_info[stash_count]="$(git rev-list --walk-reflogs --ignore-missing --count refs/stash)"
    if (( git_info[stash_count] > 0 )); then
      prompt_segments[git_stash]+=" "
      prompt_segments[git_stash]+="${segment_left}"
      prompt_segments[git_stash]+="${fg_yellow}\$^${git_info[stash_count]}"
      prompt_segments[git_stash]+="${segment_right}"
    fi

    #
    # git_action
    #
    if [[ -n ${git_info[action]} ]]; then
      prompt_segments[git_action]+=" "
      prompt_segments[git_action]+="${segment_left}"
      prompt_segments[git_action]+="${fg_red}${git_info[action]:u}"
      prompt_segments[git_action]+="${segment_right}"
    fi
  fi

  case "$_rc" in
    0) prompt_color="${fg_green}"   ;;
    1) prompt_color="${fg_red}"     ;;
    *) prompt_color="${fg_magenta}" ;;
  esac

  prompt_segments[prompt]=" 󱞪 ${bold}${prompt_color}[${_rc}]%#${reset} "

  PROMPT=""
  for segment in "${prompt_order[@]}"; do
    PROMPT+="${prompt_segments[${segment}]}"
  done
}

zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git*' check-for-changes true
zstyle ':vcs_info:git*' formats \
  $'branch=%b\nrepo=%r\nsubdir=%S\nstaged=%c\nunstaged=%u'
zstyle ':vcs_info:git*' actionformats \
  $'branch=%b\nrepo=%r\nsubdir=%S\nstaged=%c\nunstaged=%u\naction=%a'
