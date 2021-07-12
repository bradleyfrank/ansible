# Brad's Bootstrapping & dotfiles Manager

Ansible playbook for bootstrapping macOS/Linux workstations and managing dotfiles.

**Supported systems:** *macOS, Ubuntu, Pop!_OS*

## Install & Run

```shell
bbdm=https://bbdm.franklybrad.com/install && \
case $(uname -s) in Darwin) curl -sO $bbdm ;; Linux) wget -q $bbdm ;; esac
```

Usage:

```text
sh install [-g git_branch] [-d]
  -g  Specify the git branch to run (default: main)
  -d  Run the dotfiles playbook only
```

This repo runs entirely local, no remote connections.

* Requires `sudo` privileges
* Prompts for:
  * Ansible vault password (saved to `~/.ansible/vault`)
  * System ownership (personal vs employer)
  * Email address
* Creates `inventory.json` with the above host-specific variables
* Installs repository to `~/.local/opt/bbdm`

***Mac App Store:*** log in to the App Store to install apps via `mas` (skips if not authenticated)

### Settings

To regenerate `inventory.json` anytime, run the following Ansible command from the `bbdm` install directory, replacing the `{{ email_address }}` and `{{ work_system }}` placeholders.

```shell
ansible localhost \
  --module-name ansible.builtin.template \
  --args "src=setup/templates/inventory.json.j2 dest=inventory.json" \
  --extra-vars "ansible_system=$(uname -s)" \
  --extra-vars "email={{ email_address }}" \
  --extra-vars "work_system={{ true|false }}"
```

If `work_system` is **true**, the following tasks are skipped:

* Managing `~/.ssh/config`
* Cloning personal GitHub repositories
