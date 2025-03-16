ZSH_AUTOLOAD="${HOME}/.local/share/zsh/autoload.zsh"

reload() {
  print "rm -f ${HOME}/.config/zsh/.zcompdump" >> "$ZSH_AUTOLOAD"
  print "autoload -Uz compinit && compinit" >> "$ZSH_AUTOLOAD"
  if [[ -n $VIRTUAL_ENV ]]; then
    deactivate
    print "benv activate" >> "$ZSH_AUTOLOAD"
  fi
  exec zsh
}

if [[ -e "$ZSH_AUTOLOAD" ]]; then
  source "$ZSH_AUTOLOAD"
  rm -f "$ZSH_AUTOLOAD"
fi
