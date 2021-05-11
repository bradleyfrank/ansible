#!/usr/bin/env sh

# ----- global variables ----- #

CHECKOUT_DIR="$(mktemp -d)"
SYSTEM_TYPE="$(uname -s | tr '[:upper:]' '[:lower:]')"

case "$SYSTEM_TYPE" in
  darwin) SUDOERS_D="/private/etc/sudoers.d" ;;
  linux)  SUDOERS_D="/etc/sudoers.d"         ;;
esac

HOMEBREW_URL="https://raw.githubusercontent.com/Homebrew/install/master/install.sh"
ANSIBLE_REPO_URL="https://github.com/bradleyfrank/ansible.git"
ANSIBLE_REPO_BRANCH="main"
ANSIBLE_REPO_PLAYBOOK="bootstrap"
ANSIBLE_REPO_SKIP_TAGS="never"


# ----- functions ----- #

trap cleanup INT

cleanup() {
  [ -e "$SUDOERS_D_TMP" ] && sudo rm -f "$SUDOERS_D_TMP"
  [ -e "$CHECKOUT_DIR" ] && rm -rf "$CHECKOUT_DIR"
}

usage() {
    echo "Usage: [-b | -d] [-g git_branch] [-h]"
    echo "  -b  Run the bootstrap playbook. (default)"
    echo "  -d  Run the dotfiles playbook."
    echo "  -g  Specify the Ansible repo git branch to run. (default: main)"
    echo "  -h  Print this help menu and quit."
    echo
    echo "Skip Tags: [-mc]"
    echo "  -m  Do not install Mac App Store apps [on macOS systems]. (tag: mac_app_store)"
    echo "  -c  Do not manage ssh config file. (tag: ssh_config)"
}

create_tmp_sudoers() {
  [ -e "$SUDOERS_D_TMP" ] && sudo rm -rf "$SUDOERS_D_TMP"
  SUDOERS_D_TMP="${SUDOERS_D}/99-ansible-$(date +%F)"
  sudo --validate --prompt "Enter sudo password: " # reset sudo timer for following command
  printf "%s ALL=(ALL) NOPASSWD: ALL\n" "$(id -un)" | sudo VISUAL="tee" visudo -f "$SUDOERS_D_TMP"
  printf "\n" # insert newline for readability
}

create_vault_file() {
  vaultfile="$HOME/.ansible/vault"
  [ -s "$vaultfile" ] && return 0
  [ ! -d "$HOME/.ansible" ] && mkdir "$HOME/.ansible"

  vaultpw=$(
    exec < /dev/tty
    tty_settings=$(stty -g) # save current tty settings
    trap 'stty "$tty_settings"' EXIT INT TERM
    stty -echo || exit # disable terminal local echo
    printf "Enter vault password: " > /dev/tty
    IFS= read -r password; ret=$?
    echo > /dev/tty # insert newline for readability
    printf "%s\n" "$password"
    exit "$ret"
  )

  printf "%s" "$vaultpw" > "$vaultfile"
  chmod 0400 "$vaultfile"
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

not_supported() {
  echo "Unsupported OS, aborting..." >&2
  exit 1
}

bootstrap_os() {
  case "$SYSTEM_TYPE" in
    darwin) bootstrap_macos ;;
    linux)  bootstrap_linux ;;
    *)      not_supported   ;;
  esac
}

bootstrap_macos() {
  if [ ! -x /usr/local/bin/brew ]; then CI=1 /bin/bash -c "$(curl -fsSL "$HOMEBREW_URL")"
  else softwareupdate --install --all
  fi
  brew install python3 git
}

bootstrap_linux() {
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
    *) not_supported ;;
  esac
}

pre_ansible_run() {
  python3 -m pip install --user --upgrade pip
  python3 -m pip install --user ansible docker github3.py

  PATH="$PATH:$(python3 -m site --user-base)/bin"
  PYTHONPATH="$PYTHONPATH:$(python3 -m site --user-site)"
  export PATH PYTHONPATH

  git clone "$ANSIBLE_REPO_URL" "$CHECKOUT_DIR"
  cd "$CHECKOUT_DIR" >/dev/null 2>&1 || return 1
  git checkout "$ANSIBLE_REPO_BRANCH"
  cd - >/dev/null 2>&1 || return 1

  ansible-galaxy collection install -r "$CHECKOUT_DIR"/requirements.yml
}

ansible_playbook() {
  case "$ANSIBLE_REPO_PLAYBOOK" in
    bootstrap)
      ansible-playbook --ask-become-pass --skip-tags "$ANSIBLE_REPO_SKIP_TAGS" playbooks/bootstrap.yml ;;
    dotfiles)
      ansible-playbook --skip-tags "$ANSIBLE_REPO_SKIP_TAGS" playbooks/dotfiles.yml ;;
  esac
}

ansible_run() {
  cd "$CHECKOUT_DIR" >/dev/null 2>&1 || return 1
  if ansible_playbook; then
    cd - >/dev/null 2>&1 || return 1
    [ -e "$HOME"/.dotfiles ] && rm -rf "$HOME"/.dotfiles
    mv "$CHECKOUT_DIR" "$HOME"/.dotfiles
    return 0
  else
    cd - >/dev/null 2>&1 || return 1
    return 1
  fi
}


# ----- main ----- #

while getopts ':bdg:mch' opt; do
  case "$opt" in
    b) ANSIBLE_REPO_PLAYBOOK="bootstrap" ;;
    d) ANSIBLE_REPO_PLAYBOOK="dotfiles"  ;;
    g) ANSIBLE_REPO_BRANCH="$OPTARG"     ;;
    m) ANSIBLE_REPO_SKIP_TAGS="${ANSIBLE_REPO_SKIP_TAGS},mac_app_store" ;;
    c) ANSIBLE_REPO_SKIP_TAGS="${ANSIBLE_REPO_SKIP_TAGS},ssh_config"    ;;
    h) usage ; exit 0 ;;
    *) usage ; exit 1 ;;
  esac
done

case "$ANSIBLE_REPO_PLAYBOOK" in
  bootstrap) create_tmp_sudoers ; create_vault_file ; keep_awake ; bootstrap_os ;;
  dotfiles)  create_vault_file ;;
  *)         exit 1 ;;
esac

pre_ansible_run ; rc=$? ; [ $rc = 1 ] && { cleanup ; exit 1 ; }
ansible_run ; rc=$? ; cleanup ; exit $rc
