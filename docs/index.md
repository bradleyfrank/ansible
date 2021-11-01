# Brad's Bootstrapping & dotfiles Manager

```shell
curl -sO https://bbdm.franklybrad.com/install
```

***Note:*** *Do not pipe `curl` into `sh` as Ansible won't run in interactive mode and thus will skip the setup prompts.*

Usage:

```text
sh install [-g git_branch] [-d]
  -g  Specify the git branch to run (default: main)
  -d  Run the dotfiles playbook only
```
