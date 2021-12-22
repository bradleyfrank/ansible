# Brad's Bootstrapping & dotfiles Manager

Ansible playbook for bootstrapping macOS & Fedora Linux workstations, and managing dotfiles.

## About

This repository was created to handle three main personal computer setups:

1. macOS systems of any kind
2. Fedora Workstation edition running Gnome or KDE desktop
3. Fedora Server edition running without a desktop

All workstations are unique in a way that cannot be fully captured in configs or variables within the repository — unlike a server where you could be installing from a known pre-built image or kickstart — so the playbooks are designed with *no assumed knowledge of the system*. To address host-specific settings, variables are stored alongside the inventory.

It was designed to be run *completely local* on a brand-new installed system, even with a bare amount of packages. There is no concept of remote connections for these playbooks. To that end, there are multiple stages of bootstrapping handled by the `install` script:

1. **Bootstrapping the OS:** Installs the necessary packages to check out the repository and run Ansible. On macOS this includes Homebrew (which also installs the Command Line Tools). For both, it includes Python and Pip.

2. **Bootstrapping Ansible:** A separate playbook in the `setup` directory runs with its own Ansible configuration, prompting for the vault password and host settings, creating the inventory file for the main playbooks to use.

3. **Bootstrapping the system:** The `bootstrap` playbook is run to pull in additional software, configure the OS and applications, and setup the user environment (e.g. terminal, desktop, etc).

The `dotfiles` playbook is imported by `bootstrap`, and is meant to be run on it's own periodically as user preferences and settings grow, adjust, or change. It can be run without `bootstrap`, for example on a shared server, but it assumes all prequisite packages are installed.

### Reusability

The playbooks themselves are opinionated: I don't rely on external roles so they are heavily personalized and customized to my needs. In theory, they can meet the needs of others, i.e. by forking this repository and modifying the `group_vars` variables and various configs in `files` and `templates` to suit your needs.

## Installing

```shell
curl -sO https://bbdm.franklybrad.com/install
```

*Do not pipe `curl` into `sh` as Ansible won't run in interactive mode and thus will skip the setup prompts.*

## Running

### Notes

#### On requiring admin privileges

The `install` script requires `sudo` access in Fedora Linux to install OS packages. The `bootstrap` playbook requires `sudo` access in Fedora Linux *and* macOS. The `dotfiles` playbook is designed to never require `sudo` access for either system.

#### Additional manual pre and post tasks

* For macOS, log in to the App Store prior to running the `bootstrap` playbook to install apps via `mas` (this step will be skipped by design if not authenticated).
* A full reboot is required on either system after a successful bootstrap.

#### SSH keys & Github

The `setup` playbook will prompt for a comma-separated list of SSH types for the `dotfiles` playbook to generate. For each type specified, `setup` will generate a passphrase — encrypted by Ansible Vault — and store the encrypted passphrase in the `inventory.yml` file (this allows `dotfiles` to remain idempotent). A user readable copy is saved to `~/.ssh/` for each key type, with the suffix `.passphrase`. *It should be deleted upon recording the passphrase in your password manager of choice.*

If `upload_ssh_key_github` is set to `True`, and a SSH key type of `ed25519` or `rsa` is generated, the key will be uploaded to Github.

### Usage

```text
sh install [-g git_branch] [-d]
  -g  Specify the git branch to run (default: main)
  -d  Run the dotfiles playbook only
```

*The script prevents sleep/hibernation/idle with `caffeinate` for macOS and `systemd-inhibit` for Fedora Linux.*

1. Prompts for:
    1. Ansible vault password (saved to `~/.ansible/vault`)
    2. Hostname
    3. Email address (for the global `~/.gitconfig` settings)
    4. SSH key types to generate (dsa,ecdsa,ed25519,rsa|None)
    5. Clone all personal GitHub repos (True|False)
    6. Manage `~/.ssh/config` (True|False)
    7. Upload SSH key to Github (True|False)
    8. Install employer settings and scripts (True|False)
2. Creates `~/.ansible/inventory.yml` from the above answers

## Managing Inventory

To regenerate `~/.ansible/inventory.yml`, run the following command from the top level of the repository:

```shell
ANSIBLE_CONFIG=setup/setup.cfg ansible-playbook setup/site.yml -e "current_hostname=$(hostname -s)"
```
