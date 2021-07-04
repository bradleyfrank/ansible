#!/usr/bin/env sh

set -o errexit

# ----- global variables ----- #

ANSIBLE_REPO_BRANCH=main
ANSIBLE_REPO_PLAYBOOK=bootstrap
ANSIBLE_REPO_URL=https://github.com/bradleyfrank/ansible.git
DOTFILES_DIR="$HOME"/.dotfiles
EMAIL_ADDRESS="$(id -un)@$(uname -n)"
HOMEBREW_URL=https://raw.githubusercontent.com/Homebrew/install/master/install.sh
TIMESTAMP=$(date +%F_%T | tr -d ':-' | tr '_' '-')


# ----- functions ----- #

trap 'cleanup; trap - EXIT; exit' EXIT INT HUP TERM

cleanup() {
  [ -f "$SUDOERS_D_TMP" ] && sudo rm -f "$SUDOERS_D_TMP"
}

usage() {
    echo "sh run.sh [-g git_branch] [-b | -d] [-e email] [-w] | -h"
    echo "  -g  Specify the git branch to run (default: main)"
    echo "  -b  Run the bootstrap playbook (default)"
    echo "  -d  Run the dotfiles playbook"
    echo "  -e  Email address for config files (default: username@hostname)"
    echo "  -w  Designate a work system; skip certain tasks (default: false)"
    echo "  -h  Print this help menu and quit"
}

create_tmp_sudoers() {
  SUDOERS_D_TMP="$SUDOERS_D/ansible.$TIMESTAMP"
  printf "%s ALL=(ALL) NOPASSWD: ALL\n" "$(id -un)" | sudo VISUAL="tee" visudo -f "$SUDOERS_D_TMP"
}

bootstrap_mac() {
  SUDOERS_D=/private/etc/sudoers.d; create_tmp_sudoers

  pgrep caffeinate >/dev/null || (caffeinate -d -i -m -u &)

  if [ ! -x /usr/local/bin/brew ]; then
    CI=1 /bin/bash -c "$(curl -fsSL "$HOMEBREW_URL")"
  else
    softwareupdate --install --all
  fi

  brew install python3 git
}

bootstrap_linux() {
  SUDOERS_D=/etc/sudoers.d; create_tmp_sudoers

  # shellcheck disable=SC1091
  . /etc/os-release

  if [ "$ID" != ubuntu ] && [ "$ID" != pop ]; then exit 1; fi

  dconf write /org/gnome/desktop/session/idle-delay 'uint32 0'
  dconf write /org/gnome/settings-daemon/plugins/power/sleep-inactive-ac-timeout "'nothing'"

  sudo systemctl stop packagekit
  sudo apt-get clean
  sudo apt-get update
  sudo apt-get upgrade -y
  sudo apt-get install -y python3 python3-pip git lsb-release
}

bootstrap_ansible() {
  PATH="$PATH:$(python3 -m site --user-base)/bin"; export PATH
  python3 -m pip install --user ansible docker github3.py

  [ -d "$DOTFILES_DIR" ] && mv "$DOTFILES_DIR" "$DOTFILES_DIR.$TIMESTAMP"
  git clone "$ANSIBLE_REPO_URL" "$DOTFILES_DIR"

  cd "$DOTFILES_DIR" >/dev/null
  git checkout "$ANSIBLE_REPO_BRANCH"

  ansible-galaxy collection install -r requirements.yml

  ANSIBLE_CONFIG=setup/setup.cfg \
  ansible-playbook setup/site.yml \
    --extra-vars "email=$EMAIL_ADDRESS" \
    --extra-vars "work_system=${WORK_SYSTEM:-false}"

  cd - >/dev/null
}

ansible_run() {
  cd "$DOTFILES_DIR" >/dev/null
  case "$ANSIBLE_REPO_PLAYBOOK" in
    bootstrap) ansible-playbook --ask-become-pass playbooks/bootstrap.yml ;;
    dotfiles)  ansible-playbook playbooks/dotfiles.yml ;;
  esac
  cd - >/dev/null
}


# ----- main ----- #

while getopts ':bde:g:wh' opt; do
  case "$opt" in
    b) ANSIBLE_REPO_PLAYBOOK=bootstrap ;;
    d) ANSIBLE_REPO_PLAYBOOK=dotfiles  ;;
    e) EMAIL_ADDRESS="$OPTARG"         ;;
    g) ANSIBLE_REPO_BRANCH="$OPTARG"   ;;
    w) WORK_SYSTEM=true ;;
    h) usage; exit 0    ;;
    *) usage; exit 1    ;;
  esac
done

if [ "$ANSIBLE_REPO_PLAYBOOK" = bootstrap ]; then
  case $(uname -s) in
    Darwin) bootstrap_mac ;;
    Linux)  bootstrap_linux ;;
    *)      exit 1 ;;
  esac
fi

bootstrap_ansible
ansible_run
