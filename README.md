# Brad's Bootstrapping & dotfiles Manager

## Overview

Ansible playbooks and roles for bootstrapping macOS and Linux workstations, and managing dotfiles. The playbooks are designed with _no assumed prior knowledge of the system_, and are meant to be run on a newly installed system.

Because these playbooks are meant to be run locally instead of over SSH, the inventory is dynamic, such that the current host is assigned to groups based on Linux distro, or simply `Darwin` for macOS.

## Running the Playbooks

On macOS, in order to install apps via `mas`, log in to the App Store prior to running. Then download and run the install script:

    ```shell
    curl -sO https://dotfiles.franklybrad.com/install
    sh install
    ```

> [!TIP]
> Upon completion, a full reboot is recommended for a clean shell.

> [!TIP]
> Check the `install` script for environment variables that can be set prior to running.
> e.g. `ANSIBLE_REPO_BRANCH=develop sh install`

> [!IMPORTANT]
> Do not pipe `curl` into `sh` as Ansible won't run in interactive mode and will skip setup prompts.

### Setup Workflow

1. **Bootstrap the OS:** the `install` script installs the necessary packages to check out the repository and run Ansible; this includes Homebrew (excluding ARM systems), Python, and Git. _This script requires `sudo` access on Linux only._

2. **Bootstrap Ansible**: this playbook installs the necessary Ansible collections, and creates a host YAML file that is pre-filled with global variables (used as default values in roles).

3. **Initialize 1Password**: the user is prompted for 1Password credentials, Ansible authenticates with the option of using the GUI or just the CLI version. A new entry is created for the host machine under the category `SERVER`.

4. **System bootstrap**: runs the `play_all_roles` playbook which includes all roles and tasks, specifically `all,never` to target tasks where idompotence isn't desireable (e.g. completely resetting a dock).

## Managing Dotfiles

Run the playbook `play_dots`. Tasks that fall under dotfile management are tagged with `dots`. Add the tag `moredots` to include additional tasks that are complimentary to dotfile management.
