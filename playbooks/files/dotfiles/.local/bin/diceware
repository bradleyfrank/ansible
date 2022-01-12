#!/usr/bin/env bash

#
# Creates a N-length dicware passphrase with a N-length random number at the end.
# Author: Brad Frank
# Date: Jan 2022
# Tested: GNU bash, version 5.1.12(1)-release (x86_64-apple-darwin21.1.0)
#

main() {
  local OPTIND dice length numware; length=5 numware=0

  while getopts ':hl:n' flag; do
    case "$flag" in
      h) echo "Usage: diceware [-l(ength) <num>] [-n(umware)]"; exit 0 ;;
      l) length="$OPTARG" ;;
      n) numware=1 ;;
      *) echo "Invalid argument." >&2; exit 1 ;;
    esac
  done

  dice="$(shuf -n "$length" ~/.local/share/dict/words \
    | xargs -I{} echo {} | sed 's/.*/\u&/' | xargs | tr " " "-")"

  if [[ "$numware" -eq 1 ]]; then
    dice="${dice}-$(for _ in $(seq "$length"); do echo -n $((SRANDOM % 10)); done | xargs)"
  else
    dice="${dice%-}"
  fi

  echo "$dice"
}

main "$@"
