# shellcheck disable=SC1071
#!/usr/bin/env zsh

#
# Inspiration and references:
#   https://github.com/chvolkmann/code-connect
#   https://ianloic.com/2021/02/16/vscode-remote-and-the-command-line/
#   https://zsh.sourceforge.io/Doc/Release/Expansion.html
#
# Server setup:
#   1. Add to /etc/ssh/sshd_config:
#     AllowTcpForwarding yes
#     PasswordAuthentication no
#     AuthenticationMethods publickey
#     PubkeyAuthentication yes
# Local setup:
#   1. Generate SSH keys & install on server
#   2. Add to ~/.ssh/config:
#     Host <my-server>
#       HostName <ip-address>
#       Port <port-number>
#       IdentityFile <my-ssh-key>
#   3. Add to VSCode settings.json:
#     "remote.SSH.remotePlatform": {
#       "<my-server>": "linux"
#     }
#   4. Bootstrap VSCode: code --remote=ssh-remote+<my-server> /home/<my-username>
#

declare -g VSCODE

get_bin() {
  local bin; bin=$(echo ~/.vscode-server/bin/*/bin/code(*ocNY1))
  [[ -z "$bin" ]] && { echo "VSCode remote script not found." 1>&2; exit 1; }
  VSCODE="$bin"
  return
}

get_socket() {
  local socket active_socket

  while read -r socket; do
    if socat -u OPEN:/dev/null UNIX-CONNECT:"$socket" &>/dev/null; then
      export VSCODE_IPC_HOOK_CLI="$socket"
      return
    fi
  done <<< $(echo /run/user/$UID/vscode-ipc-*.sock(=oa) | tr ' ' '\n')

  echo "VSCode IPC socket not found." 1>&2
  exit 1
}

get_bin
get_socket

$VSCODE "$@"
