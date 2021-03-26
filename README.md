# Brad's Bootstrapping & dotfiles Manager

Ansible playbook for bootstrapping macOS/Linux workstations and managing dotfiles.

* **Supported OS:** *macOS, Fedora, Ubuntu, Pop!_OS*

## Prepping & Running

The `run.sh` script updates the OS and installs Ansible and its dependencies before running the playbook.

```none
Usage: [-b | -d] [-g git_branch] [-h]
    -b  Run the bootstrap playbook. (default)
    -d  Run the dotfiles playbook.
    -g  Specify the Ansible repo git branch to run (default: 'main').
    -h  Print this help menu and quit.

Skip Tags: [-mc]
    -m  Do not install Mac App Store apps [on macOS systems]. (tag: mac_app_store)
    -c  Do not manage ssh config file. (tag: ssh_config)
```

* For macOS ensure iCloud and the Mac App Store are authenticated to the appropriate account (allows `mas` to install apps; skip with `-m`)
* The script will prompt for the vault password and create `~/.ansible/vault` (decrypts `.ssh/config`; skip with `-c`)

To start with `curl` (i.e. **macOS**):

```shell
curl -O https://bradleyfrank.github.io/ansible/run.sh && bash run.sh <args>
```

To start with `wget` (i.e. **Linux**):

```shell
wget https://bradleyfrank.github.io/ansible/run.sh && bash run.sh <args>
```
