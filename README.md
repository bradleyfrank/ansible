# Brad's Bootstrapping & dotfiles Manager

Ansible playbook for bootstrapping macOS/Linux workstations and managing dotfiles.

**Supported systems:** *macOS, Fedora, Ubuntu, Pop!_OS*

## Installing

To install with `curl` (i.e. **macOS**):

```shell
curl -O https://raw.githubusercontent.com/bradleyfrank/ansible/main/run.sh
```

To install with `wget` (i.e. **Linux**):

```shell
wget https://raw.githubusercontent.com/bradleyfrank/ansible/main/run.sh
```

## Running

This repo runs entirely local, no remote connections.

```text
sh run.sh [-g git_branch] [-b | -d] [-e email] [-s] | -h
  -g  Specify the git branch to run (default: 'main')
  -b  Run the bootstrap playbook (default)
  -d  Run the dotfiles playbook
  -e  Set the email address for this system
  -s  Manage ssh config for this system (default: false)
  -h  Print this help menu and quit
```

* Creates an `inventory` file with host-specific variables
* Prompts for the Ansible vault password (saved to `~/.ansible/vault`)
* Ansible is installed via `pip` on all systems
* The `bootstrap` playbook requires `sudo` privileges for any system
* Log in to the Mac App Store to install apps via `mas` (skips if not authenticated)
