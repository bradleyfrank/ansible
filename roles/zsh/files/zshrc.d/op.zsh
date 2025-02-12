if (( ${OPCLI:=0} == 0 )); then
  if ! op whoami &> /dev/null; then
    eval "$(op signin)"
  fi
fi
