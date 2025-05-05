# TODO

## SSH keys and agent

- Two options:
    - Generate ssh keys & use [`keychain`](https://github.com/funtoo/keychain) to manage agent
    - Don't generate ssh keys & use 1Password to manage agent
- Use 1Password for agent by default
- I can test if 1Password agent is enabled by checking that `agent.sock` exists

## Ungrouped

- fix ssh-agent not adding keys on Linux
- fix `ffmpeg` packages for Fedora
- Archive an existing host in 1Password if hostname matches
- dconf package variables should be simplified
- Replace `cht.sh` script with `curl` alias
- Docker role should use `dnf5`
- for macOS, is there a `defaults` for removing tiling margin?
- lesshst and viminfo are being recreated even with env var set
