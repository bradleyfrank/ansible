# Brad's Bootstrapping & dotfiles Manager

Ansible playbook for bootstrapping macOS/Linux workstations and managing dotfiles.

**Supported systems:** *macOS, Ubuntu, Pop!_OS*

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

* Installs repository to `~/.dotfiles`
* Creates `inventory.json` with host-specific variables
* Prompts for the Ansible vault password (saved to `~/.ansible/vault`)
* Ansible is installed via `pip` on all systems
* The `bootstrap` playbook requires `sudo` privileges for any system
* Log in to the Mac App Store to install apps via `mas` (skips if not authenticated)

### Inventory

To regenerate `~/.dotfiles/inventory.json` anytime, run the following Ansible command, replacing the `{{ email_address }}` and `{{ work_system }}` placeholders.

```shell
ansible localhost \
  --module-name ansible.builtin.template \
  --args "src=setup/templates/inventory.json.j2 dest=$HOME/.dotfiles/inventory.json" \
  --extra-vars "ansible_system=$(uname -s)" \
  --extra-vars "email={{ email_address }}" \
  --extra-vars "work_system={{ true|false }}"
```

### Work Systems

Passing the `-w` flag skips the following tasks:

* Managing `~/.ssh/config`
* Cloning all personal GitHub repositories
