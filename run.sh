#!/usr/bin/env bash

# ----- global variables ----- #

declare -A ANSIBLE_REPO
declare -a SKIP_TAGS

CHECKOUT_DIR="$(mktemp -d)"
SYSTEM_TYPE="$(uname -s | tr '[:upper:]' '[:lower:]')"

case "$SYSTEM_TYPE" in
  darwin) SUDOERS_D="/private/etc/sudoers.d" ;;
   linux) SUDOERS_D="/etc/sudoers.d"         ;;
esac

ANSIBLE_REPO[url]="https://github.com/bradleyfrank/ansible.git"
ANSIBLE_REPO[branch]="main"
ANSIBLE_REPO[playbook]="dotfiles"
ANSIBLE_REPO[localhost_yml]="$CHECKOUT_DIR/inventories/host_vars/localhost.yml"


# ----- functions ----- #

trap cleanup SIGINT

function cleanup() {
  [[ -e "$SUDOERS_D_TMP" ]] && sudo rm -f "$SUDOERS_D_TMP"
  [[ -e "$CHECKOUT_DIR" ]] && rm -rf "$CHECKOUT_DIR"
}

function usage() {
    echo "Usage: [-b | -d] [-g git_branch] [-h]"
    echo "  -b  Run the bootstrap playbook."
    echo "  -d  Run the dotfiles playbook (default)."
    echo "  -g  Specify the Ansible repo git branch to run."
    echo "  -h  Print this help menu and quit."
    echo
    echo "Skip Tags: [-mc]"
    echo "  -m  Do not install Mac App Store apps [on macOS systems]. (tag: mac_app_store)"
    echo "  -c  Do not manage ssh config file. (tag: ssh_config)"
}

function create_tmp_sudoers() {
  [[ -e "$SUDOERS_D_TMP" ]] && sudo rm -rf "$SUDOERS_D_TMP"
  SUDOERS_D_TMP="${SUDOERS_D}/99-ansible-$(date +%F)"
  sudo --validate --prompt "Enter sudo password: " # reset sudo timer for following command
  printf "%s ALL=(ALL) NOPASSWD: ALL\n" "$(id -un)" | sudo VISUAL="tee" visudo -f "$SUDOERS_D_TMP"
  printf "\n\n" # insert newlines for readability
}

function create_vault_file() {
  local vaultpw vaultfile="$HOME/.ansible/vault"
  [[ -e "$vaultfile" ]] && return 0
  [[ ! -d "$HOME/.ansible" ]] && mkdir "$HOME/.ansible"
  read -r -s -p "Enter vault password: " vaultpw
  printf "%s" "$vaultpw" > "$vaultfile"
  chmod 0400 "$vaultfile"
  printf "\n\n" # insert newlines for readability
}

function keep_awake() {
  case "$SYSTEM_TYPE" in
    darwin)
      kill "$(pgrep caffeinate)" &> /dev/null
      (caffeinate -d -i -m -u &)
      ;;
    linux)
      dconf write /org/gnome/desktop/session/idle-delay 'uint32 0'
      dconf write /org/gnome/settings-daemon/plugins/power/sleep-inactive-ac-timeout "'nothing'"
      ;;
  esac
}

function not_supported() {
  echo "Unsupported OS, aborting..." >&2
  exit 1
}

function bootstrap_os() {
  case "$SYSTEM_TYPE" in
    darwin) bootstrap_macos ;;
    linux ) bootstrap_linux ;;
    *     ) not_supported   ;;
  esac
}

function bootstrap_macos() {
  local homebrew_url="https://raw.githubusercontent.com/Homebrew/install/master/install.sh"
  keep_awake
  softwareupdate --install --all
  [[ ! -x /usr/local/bin/brew ]] && CI=1 /bin/bash -c "$(curl -fsSL "$homebrew_url")"
  brew install ansible git
}

function bootstrap_linux() {
  keep_awake

  case "$(sed -rn 's/^ID="?([a-z]+)"?/\1/p' /etc/os-release)" in
    fedora)
      sudo dnf clean all
      sudo dnf makecache
      sudo dnf upgrade -y
      sudo dnf install -y ansible git flatpak
      ;;
    ubuntu|pop)
      sudo apt-get clean
      sudo apt-get update
      sudo apt-get upgrade -y
      sudo apt-get install -y ansible git flatpak
      ;;
    *) not_supported ;;
  esac
}

function pre_ansible_run() {
  if ! type ansible &> /dev/null; then
    python3 -m pip install --user ansible || return 1
    PATH="$PATH:$(python3 -m site --user-base)/bin"
    export PATH
  fi

  git clone "${ANSIBLE_REPO[url]}" "$CHECKOUT_DIR" || return 1
  pushd "$CHECKOUT_DIR" &> /dev/null || return 1
  git checkout "${ANSIBLE_REPO[branch]}" || return 1
  popd &> /dev/null || return 1

  ansible-galaxy collection install -r "$CHECKOUT_DIR"/requirements.yml || return 1
}

function ansible_playbook() {
  local skip_tags
  skip_tags="$(tr ' ' ',' <<< "${SKIP_TAGS[*]}")"

  case "${ANSIBLE_REPO[playbook]}" in
    bootstrap) ansible-playbook --ask-become-pass --skip-tags "$skip_tags" playbooks/bootstrap.yml ;;
    dotfiles ) ansible-playbook --skip-tags "$skip_tags" playbooks/dotfiles.yml                    ;;
  esac
}

function ansible_run() {
  pushd "$CHECKOUT_DIR" &> /dev/null || return 1
  if ansible_playbook; then
    popd &> /dev/null || return 1
    [[ -e "$HOME"/.dotfiles ]] && rm -rf "$HOME"/.dotfiles
    mv "$CHECKOUT_DIR" "$HOME"/.dotfiles
    return 0
  else
    popd &> /dev/null || return 1
    return 1
  fi
}


# ----- main ----- #

while getopts ':bdg:mch' opt; do
  case "$opt" in
    b) ANSIBLE_REPO[playbook]="bootstrap" ;;
    d) ANSIBLE_REPO[playbook]="dotfiles"  ;;
    g) ANSIBLE_REPO[branch]="$OPTARG"     ;;
    m) SKIP_TAGS+=("mac_app_store")       ;;
    c) SKIP_TAGS+=("ssh_config")          ;;
    h) usage ; exit 0 ;;
    *) usage ; exit 1 ;;
  esac
done

if [[ "${ANSIBLE_REPO[playbook]}" == "bootstrap" ]]; then
  create_tmp_sudoers
  create_vault_file
  bootstrap_os
elif [[ "${ANSIBLE_REPO[playbook]}" == "dotfiles" ]]; then
  create_vault_file
else
  exit 1
fi

if ! pre_ansible_run; then cleanup; exit 1; fi
if ! ansible_run; then cleanup; exit 1; else exit 0; fi
