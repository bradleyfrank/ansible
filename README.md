# Brad's Bootstrapping & dotfiles Manager

## Overview

Ansible playbooks and roles for bootstrapping macOS and Linux workstations, and managing dotfiles. The playbooks are designed with _no assumed prior knowledge of the system_, and are meant to be run on a newly installed system.

Because these playbooks are meant to be run locally instead of over SSH, the inventory is dynamic, such that the current host is assigned to groups based on Linux distro, or simply `Darwin` for macOS.

## Running the Playbooks

1. On macOS, authenticate to the App Store (required if using `mas`)
2. Clone the repository locally
3. `cd` into the git repo and run `sh install`

> [!TIP]
> Run `sh install -h` to show available script flags

### Setup Workflow

1. **Bootstrap the OS:** the `install` script installs necessary packages to setup and run Ansible; this includes e.g. Homebrew, Python, and Git. _This script requires `sudo` access on Linux only._

2. **Bootstrap Ansible**: this playbook installs the necessary Ansible collections, and creates a host YAML file that is pre-filled with global variables (used as default values in roles).

3. **Initialize 1Password**: the user is prompted for 1Password credentials, Ansible authenticates with the option of using the GUI or just the CLI version. A new entry is created for the host machine under the category `SERVER`.

4. **System bootstrap**: runs the `play_all_roles` playbook which includes all roles and tasks, specifically `all,never` to target tasks where idompotence isn't desireable (e.g. completely resetting a dock).

> [!NOTE]
> Upon completion, a full reboot is recommended for a clean shell.

## Managing Dotfiles

Run the playbook `play_dots`. Tasks that fall under dotfile management are tagged with `dots`. Add the tag `moredots` to include additional tasks that are complimentary to dotfile management.

> [!TIP]
> A Makefile is provided to use frequently used playbook settings; e.g. `make dots`
