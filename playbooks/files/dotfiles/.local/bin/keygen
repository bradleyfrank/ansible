#!/usr/bin/env bash

#
# Generates a password-protected SSH key.
# Author: Brad Frank
# Date: Jan 2022
# Tested: GNU bash, version 5.1.12(1)-release (x86_64-apple-darwin21.1.0)
#

main() {
  local key comment password
  key="$HOME/.ssh/${1:-id_rsa}"
  while [[ -e "$key" ]]; do key="$HOME"/.ssh/id_"$(shuf -n 1 ~/.local/share/dict/words)"; done
  comment="$(id -un)@$(uname -n) on $(date --iso-8601=minute)"
  password="$(shuf -n 5 ~/.local/share/dict/words | xargs | tr ' ' '-')"
  ssh-keygen -q -t rsa -b 4096 -N "$password" -C "$comment" -f "$key"
  echo "$key : $password"
}

main "$1"
