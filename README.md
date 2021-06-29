# Brad's Bootstrapping & dotfiles Manager

Ansible playbook for bootstrapping macOS/Linux workstations and managing dotfiles.

**Supported systems:** *macOS, Ubuntu, Pop!_OS*

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
sh run.sh [-g git_branch] [-b | -d] [-e email] [-w] | -h
  -g  Specify the git branch to run (default: main)
  -b  Run the bootstrap playbook (default)
  -d  Run the dotfiles playbook
  -e  Email address for config files (default: username@hostname)
  -w  Designate a work system; skip certain tasks (default: false)
  -h  Print this help menu and quit
```

* Creates an `inventory.yml` file with host-specific variables
* Prompts for the Ansible vault password (saved to `~/.ansible/vault`)
* Ansible is installed via `pip` on all systems
* The `bootstrap` playbook requires `sudo` privileges for any system
* Log in to the Mac App Store to install apps via `mas` (skips if not authenticated)

### Inventory

To regenerate `inventory.yml` anytime, run the following Ansible command, replacing the `{{ email }}` and `{{ work_system }}` placeholders.

```shell
ansible localhost \
  --module-name ansible.builtin.template \
  --args "src=playbooks/templates/inventory.yml.j2 dest=inventory.yml" \
  --extra-vars "kernel_name=$(uname -s)" \
  --extra-vars "email={{ email_address }}" \
  --extra-vars "work_system={{ true|false }}"
```

### Work Systems

Passing the `-w` flag skips the following tasks:

* Managing `~/.ssh/config`
* Cloning all personal GitHub repositories
