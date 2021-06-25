#!/usr/bin/env sh

# ----- global variables ----- #

SYSTEM_TYPE=$(uname -s | tr '[:upper:]' '[:lower:]')
case "$SYSTEM_TYPE" in
  darwin) SUDOERS_D=/private/etc/sudoers.d ;;
  linux)  SUDOERS_D=/etc/sudoers.d         ;;
esac

ANSIBLE_HOME="$HOME"/.ansible
ANSIBLE_REPO_BRANCH=main
ANSIBLE_REPO_PLAYBOOK=bootstrap
ANSIBLE_REPO_URL=https://github.com/bradleyfrank/ansible.git
ANSIBLE_VAULT="$ANSIBLE_HOME/vault"
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
  [ -e "$SUDOERS_D_TMP" ] && sudo rm -rf "$SUDOERS_D_TMP"
  SUDOERS_D_TMP="${SUDOERS_D}/99-ansible-${TIMESTAMP}"
  sudo --validate --prompt "Enter sudo password: " # reset sudo timer for following command
  printf "%s ALL=(ALL) NOPASSWD: ALL\n" "$(id -un)" | sudo VISUAL="tee" visudo -f "$SUDOERS_D_TMP"
  printf "\n" # insert newline for readability
}

create_vault_file() {
  [ -s "$ANSIBLE_VAULT" ] && return 0

  printf "%s" "$(
    exec < /dev/tty
    tty_settings=$(stty -g) # save current tty settings
    trap 'stty "$tty_settings"' EXIT INT TERM
    stty -echo || exit # disable terminal local echo
    printf "Enter vault password: " > /dev/tty
    IFS= read -r password; rc=$?
    echo > /dev/tty # insert newline for readability
    printf "%s\n" "$password"
    exit "$rc"
  )" > "$ANSIBLE_VAULT"

  chmod 0400 "$ANSIBLE_VAULT"
}

keep_awake() {
  case "$SYSTEM_TYPE" in
    darwin)
      kill "$(pgrep caffeinate)" >/dev/null 2>&1
      (caffeinate -d -i -m -u &)
      ;;
    linux)
      dconf write /org/gnome/desktop/session/idle-delay 'uint32 0'
      dconf write /org/gnome/settings-daemon/plugins/power/sleep-inactive-ac-timeout "'nothing'"
      ;;
  esac
}

bootstrap_os() {
  case "$SYSTEM_TYPE" in
    darwin) bootstrap_macos ;;
    linux)  bootstrap_linux ;;
    *)      exit 1          ;;
  esac

  PATH="$PATH:$(python3 -m site --user-base)/bin"; export PATH
  python3 -m pip install --user ansible docker github3.py
}

bootstrap_macos() {
  if [ ! -x /usr/local/bin/brew ]; then CI=1 /bin/bash -c "$(curl -fsSL "$HOMEBREW_URL")"
  else softwareupdate --install --all
  fi
  brew install python3 git
}

bootstrap_linux() {
  sudo systemctl stop packagekit
  case "$(sed -rn 's/^ID="?([a-z]+)"?/\1/p' /etc/os-release)" in
    fedora)
      sudo dnf clean all
      sudo dnf makecache
      sudo dnf upgrade -y
      sudo dnf install -y python3 python3-pip git redhat-lsb-core
      ;;
    ubuntu|pop)
      sudo apt-get clean
      sudo apt-get update
      sudo apt-get upgrade -y
      sudo apt-get install -y python3 python3-pip git lsb-release
      ;;
    *) exit 1 ;;
  esac
}

ansible_run() {
  [ -d "$DOTFILES_DIR" ] && mv "$DOTFILES_DIR" "${DOTFILES_DIR}.${TIMESTAMP}"

  git clone "$ANSIBLE_REPO_URL" "$DOTFILES_DIR"
  cd "$DOTFILES_DIR" >/dev/null 2>&1 || return 1
  git checkout "$ANSIBLE_REPO_BRANCH"

  ansible localhost \
    --module-name ansible.builtin.template \
    --args "src=playbooks/templates/inventory.yml.j2 dest=inventory.yml" \
    --extra-vars "email=$EMAIL_ADDRESS" \
    --extra-vars "work_system=${WORK_SYSTEM:-false}"

  ansible-galaxy collection install -r requirements.yml

  case "$ANSIBLE_REPO_PLAYBOOK" in
    bootstrap) ansible-playbook --ask-become-pass playbooks/bootstrap.yml ;;
    dotfiles)  ansible-playbook playbooks/dotfiles.yml ;;
  esac
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

[ ! -d "$ANSIBLE_HOME" ] && mkdir "$ANSIBLE_HOME"

if [ "$ANSIBLE_REPO_PLAYBOOK" = bootstrap ]; then
  create_tmp_sudoers
  keep_awake
  bootstrap_os
fi

create_vault_file
ansible_run
