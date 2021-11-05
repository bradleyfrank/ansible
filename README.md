# Brad's Bootstrapping & dotfiles Manager

Ansible playbook for bootstrapping macOS/Linux workstations and managing dotfiles.

**Supported systems:** *macOS, Fedora, Ubuntu, Pop!_OS*

## Installing

```shell
curl -sO https://bbdm.franklybrad.com/install
```

**Do not pipe `curl` into `sh` as Ansible won't run in interactive mode and thus will skip the setup prompts.**

## Running

Usage:

```text
sh install [-g git_branch] [-d]
  -g  Specify the git branch to run (default: main)
  -d  Run the dotfiles playbook only
```

1. Prompts for:
    1. Ansible vault password (saved to `~/.ansible/vault`)
    2. Hostname
    3. Email address
    4. SSH key types to generate (dsa,ecdsa,ed25519,rsa)
    5. Clone all personal GitHub repos (True|False)
    6. Manage `~/.ssh/config` (True|False)
    7. Install employer settings and scripts (True|False)
2. Creates `~/.ansible/inventory.ini` from the above answers

### Playbook Notes

* Both playbooks run entirely local, no remote connections
* Only the `bootstrap` playbook requires sudo privileges
* The `dotfiles` playbook assumes all dependencies are pre-installed
* For macOS, log in to the App Store prior to running the `bootstrap` playbook to install apps via `mas` (skips if not authenticated)

### SSH keys & Github

* Setup will prompt for a list of SSH types to generate
* Passphrases are generated, encrypted, and stored in a vars file (`~/.ansible/ssh_keys.yml`)
* Unencrypted passphrases are saved to `~/.ssh/*.passphrases` and should be deleted once copied
* If generated, `id_ed25519.pub` or `id_rsa.pub` are uploaded to Github

## Managing Inventory

To regenerate `~/.ansible/inventory.ini`, run the following command from the top level of the repository:

```shell
ANSIBLE_CONFIG=setup/setup.cfg ansible-playbook setup/site.yml -e "current_hostname=$(hostname -s)"
```

### Optional Settings

* `use_starship_prompt` (True|False): Enables Starship for the Zsh prompt; defaults to the custom `precmd` function
