#!/usr/bin/env bash

#
# A script to upload dotfiles and Brewfile to GitHub Gists.
# Author: Brad Frank
# Date: Nov 2020
# Tested: GNU bash, version 5.0.18(1)-release (x86_64-apple-darwin19.6.0)
# Requires: brew, gh
#

# $1 == description // $2 == filename
find_gist() { gh gist list | sed -rn "s/^([0-9a-fA-F]+)\s+$1.*/\1/p"; }
push() { VISUAL='tee' gh gist edit "$1" < "$2" > /dev/null; }
create() { gh gist create --public --desc "$1" "$2"; }

push_or_create() {
  local description="$1" filename="$2"
  gist_id="$(find_gist "$description")"
  if [[ -n "$gist_id" ]]; then push "$gist_id" "$filename"
  else create "$description" "$filename"
  fi
}

gist_dotfiles() {
  local dotfiles filename description
  dotfiles=( "$HOME/.zshrc" "$HOME/.tmux.conf" "$HOME/.vimrc" "$HOME/.gitconfig" )

  for filename in "${dotfiles[@]}"; do
    description="$(hostname -s)-$(basename "$filename")"
    push_or_create "$description" "$filename"
  done
}

gist_brewfile() {
  cd "$(mktemp -d)" > /dev/null || return
  brew bundle dump > /dev/null
  push_or_create "$(hostname -s)-Brewfile" Brewfile
}

gist_dotfiles
gist_brewfile
