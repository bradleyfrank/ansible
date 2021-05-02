#!/usr/bin/env bash

#
# Swaps symlinks to different versions of Terraform and Helm binaries.
# Author: Brad Frank
# Date: Feb 2021
# Tested: GNU bash, version 5.0.18(1)-release (x86_64-apple-darwin19.6.0)
# Requires: terraform, helm
#

GREEN='\033[0;32m'
RED='\033[0;31m'
RESET='\033[0m'

case "$1" in
    -h | --help | help) echo "usage: swap [tf|helm] <to version>" ; exit ;;
    tf | terraform) app="terraform" ;;
    helm) app="helm" ;;
esac

to_version="$2"
app_to_unlink="$(readlink /usr/local/bin/$app)"
app_to_symlink="${app}${to_version}"

if [[ ! -e /usr/local/bin/"$app_to_symlink" ]]; then
    echo -e "${RED}No ${app_to_symlink} found. No changes made.${RESET}"
    exit 1
fi

pushd /usr/local/bin &> /dev/null || return 1

rm "$app"
echo -e "${RED}${app_to_unlink} unlinked${RESET}"

ln -s "$app_to_symlink" "$app"
echo -e "${GREEN}${app_to_symlink} active${RESET}"

popd &> /dev/null || return 1
