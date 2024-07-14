# Brad's Bootstrapping & dotfiles Manager

## Overview

Ansible playbooks and roles for bootstrapping macOS and Linux workstations, and managing dotfiles. The playbooks are designed with _no assumed prior knowledge of the system_, and are meant to be run on a newly installed system. They are tested on the following system types:

1. **macOS systems** `x86_64`, `arm64`
2. **Linux systems** `x86_64`
    1. **Fedora Workstation edition** (spins may work but are unsupported)
    2. **Fedora Server edition**
    3. **Ubuntu Desktop LTS** (flavors may work but are unsupported)
    4. **Ubuntu Server LTS**
    5. **Linux Mint Debian Edition**

## Running the Playbooks

1. On macOS, log in to the App Store prior to running bootstrap, in order to install apps via `mas`
2. Create a GitHub fine-grained token with the following account permissions:
    * Git SSH keys: Read and write
    * SSH signing keys: Read and write
3. Create an inventory repository (see below)
4. Download and run the install script:

    ```shell
    curl -sO https://dotfiles.franklybrad.com/install
    sh install [-b] [-g git_branch]
      -b  Skip installing Homebrew on Linux (default: install)
      -g  Specify the git branch of this repo to run (default: main)
    ```

> [!IMPORTANT]
> Do not pipe `curl` into `sh` as Ansible won't run in interactive mode and will skip setup prompts.

Upon completion:

1. Record any secrets (e.g. Vault and SSH key passphrases)
2. Perform a full reboot
3. To install Logi Options+ for macOS, run `open -a "~/Downloads/logioptionsplus_installer.app"`

### Setup Workflow

1. **Bootstrapping the OS:** the `install` script installs the necessary packages to check out the repository and run Ansible; this includes Homebrew (excluding ARM systems), Python, and Git. _This script requires `sudo` access on Linux only._ Once setup, the script also runs the subsequent Ansible playbooks.

2. **Install Ansible requirements**: the `install_requirements` playbook installs the necessary Ansible collections and roles.

3. **Create localhost inventory**: the `build_inventory` playbook generates a host_vars file (for non-sensitive variables) and a localhost inventory file (for encrypted secrets), based on answers to the playbook prompts.

4. **System bootstrap**: runs the `site.yml` playbook to execute all roles. When run from the `install` script, a temporary `vault` file is created and prompts only for the become password.

5. **Export to password manager**: the `password_manager.yml` playbook imports encrypted secrets to a password manager (currently only 1Password is available).

## Building Inventory

You should create an inventory repository prior to running the playbooks. Hosts are assigned to groups based on the system type and distribution, giving flexibility to variable precedent. The group names are based on the Ansible facts `system` and `distribution`; the `all` group is also available. See [Splitting Out Host and Group Specific Data](https://docs.ansible.com/ansible/2.7/user_guide/intro_inventory.html#splitting-out-host-and-group-specific-data) for more information.

The repository should match this layout:

  * `files/`: static files
  * `group_vars/`: configurations based on system type and distribution
  * `host_vars/`: configurations for specific systems
  * `templates/`: dynamic files

The host_vars file created by the `build_inventory` playbook is meant to be committed to the inventory repo. The inventory file assigns the host groups, along with containing vaulted secrets.

## Vaulted Secrets

By default, these are the variables that are encrypted and saved to the inventory file:

1. rsa SSH key passphrase
2. ed25519 SSH key passphrase
3. GitHub personal access token

## Managing Dotfiles

Tasks that do not require sudo access are tagged with `dotfiles`. Likewise, tasks that do require sudo access are tagged with `become`. For convenience, Homebrew tasks are tagged `install`. This allows playbook runs that don't need a become password. For example:

```shell
ansible-playbook -J playbooks/site.yml --tags dotfiles --skip-tags become,install
```
