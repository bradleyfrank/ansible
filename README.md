# Brad's Bootstrapping & dotfiles Manager

Ansible playbook for bootstrapping MacOS & Fedora Linux workstations, and managing dotfiles.

## About

This repository was created to handle various computer setups:

1. **MacOS systems** (support for both Intel and Arm)
2. **Linux systems**
   1. **Fedora Workstation edition** (spins may work but are unsupported)
   2. **Fedora Server edition**
   3. **Ubuntu Desktop LTS** (flavors may work but are unsupported)
   4. **Ubuntu Server LTS**

All workstations are unique in a way that cannot be fully captured in configs or variables within the repository — unlike a server where you could be installing from a known pre-built image or kickstart — so the playbooks are designed with *no assumed knowledge of the system*. To address host-specific settings, certain variables are stored in the Ansible inventory.

The playbooks were designed to be run *completely local* on a freshly installed system, with the barest of prerequists. To that end, there are multiple stages of bootstrapping handled by the `install` script:

1. **Bootstrapping the OS:** Installs the necessary packages to check out the repository and run Ansible. On MacOS this includes Homebrew (which also installs the Command Line Tools). For both, it includes Python and Pip.

2. **Bootstrapping Ansible:** A separate playbook in the `setup` directory runs with its own Ansible configuration, prompting for the vault password and host settings, creating the inventory file for the main playbooks to use.

3. **Bootstrapping the system:** The `bootstrap` playbook is run to pull in additional software, configure the OS and applications, and setup the user environment (e.g. terminal, desktop, etc).

The `dotfiles` playbook is imported by `bootstrap`, and is meant to be run on it's own periodically as user preferences and settings grow, adjust, or change. It can be run initially without `bootstrap`, for example on a shared server, but it assumes all prerequisite packages are installed.

### Reusability

The playbooks are heavily personalized and customized to my needs, but in theory they can meet the needs of others through forking this repository and modifying the `group_vars` and `vars` variables, and other various configs in `files` and `templates` to suit your needs.

## Installing

```shell
curl -sO https://bbdm.franklybrad.com/install
```

*Do not pipe `curl` into `sh` as Ansible won't run in interactive mode and thus will skip the setup prompts.*

## Running

### Notes

#### On requiring admin privileges

* The `install` script requires `sudo` access on Fedora Linux to install OS packages.
* The `bootstrap` playbook requires `sudo` access on Fedora Linux *and* MacOS.
* The `dotfiles` playbook is designed to never require `sudo` access for either system.

#### SSH keys & Github

For SSH key types `ed25519` and `rsa`, the `setup` playbook will generate a passphrase — encrypted by Ansible Vault — and store the encrypted passphrase in `inventory.yml` (this allows `dotfiles` to remain idempotent). A user readable copy is saved to `~/.ssh/{ed25519,rsa}.passphrase`. *It should be deleted upon recording the passphrase in your password manager of choice.*

If `upload_ssh_key_github` is set to `True`, and a SSH key type of `ed25519` or `rsa` is present, the key will be uploaded to Github.

#### Additional manual pre and post tasks

* On MacOS, log in to the App Store prior to running the `bootstrap` playbook (or the `install` script) to install apps via `mas`.
* Record the SSH passphrases post-Ansible run.
* A full reboot is required after a successful bootstrap.
* To install Logi Options+ run `open -a "$HOMEBREW_PREFIX"/Caskroom/logi-options-plus/latest/logioptionsplus_installer.app`.

### Usage

```text
sh install [-g git_branch] [-d]
  -g  Specify the git branch to run (default: main)
  -d  Run the dotfiles playbook only
```

*On MacOS, the system is prevented from sleeping.*

1. Prompts for:
    1. Ansible vault password (saved to `~/.ansible/vault`)
    2. Hostname
    3. Email address (for Git commits and signing)
    4. Clone all personal GitHub repos (True|False)
    5. Manage `~/.ssh/config` (True|False)
    6. Upload SSH key to Github (True|False)
    7. Install apps from Mac App Store (True|False)
    8. Install employer settings and scripts (True|False)
2. Generates passphrases for SSH keys (saved under `~/.ssh/`)
3. Creates `~/.ansible/inventory.yml` from the above answers

## Housekeeping Tasks via Ansible

The following commands should be run from the top level of the repository.

To regenerate `~/.ansible/inventory.yml`:

```shell
ANSIBLE_CONFIG=setup/setup.cfg ansible-playbook setup/site.yml
```

To update the installed Ansible Galaxy collections:

```shell
ansible-playbook setup/collections.yml
```
