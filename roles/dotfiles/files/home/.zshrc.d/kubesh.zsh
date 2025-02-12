#
# Functions for making kubectl easier to use.
# Author: Brad Frank
# Date: Feb 2022
# Tested: zsh 5.8 (x86_64-apple-darwin19.6.0)
# Requires: fzf, jq
# Forked from:
#   - https://github.com/kubermatic/fubectl
#   - https://github.com/caedus41/fubectl
#

_fzf_k() { fzf --select-1 --exit-0 --ansi -i --height=50% --reverse --inline-info --border rounded "$@"; }

_k_ctx() {
    local ctx; ctx="$1"
    kubectl config get-contexts --output name | grep "${ctx:-}" | _fzf_k --no-multi
}

_k_namespace() {
    local ctx ns; ctx="$1" ns="$2"
    kubectl --context "$ctx" get namespaces --output name \
        | grep "${ns:-}" \
        | awk -F '/' '{print $2}' \
        | _fzf_k --no-multi
}

_k_api() {
    local ctx ns api; ctx="$1" ns="$2" api="$3"
    kubectl --context "$ctx" --namespace "$ns" api-resources --output name \
        | grep "${api:-}" \
        | _fzf_k --no-multi
}

_k_resource() {
    local ctx ns api resource; ctx="$1" ns="$2" api="$3" resource="$4"
    kubectl --context "$ctx" --namespace "$ns" get "$api" --output name \
        | grep "${resource:-}" \
        | _fzf_k --no-multi
}

_k_container() {
    kubectl --context "$1" --namespace "$2" get "$3" --output json \
        | grep "${4:-}" \
        | jq -r '.spec.containers[]|.name' \
        | _fzf_k --no-multi
}

_save_and_exec() {
    local cmd; cmd="$(tr -s ' ' <<< "$1")"
    fc -R =(echo "$cmd")
    eval "$cmd"
}

alias d='docker'
alias dc='docker compose'

dmi() {
    docker image list --format "{{json .}}" | jq -rj '.ID,"\t",.Size,"\t",.Repository,":",.Tag,"\n"'
}

alias k='kubectl'
alias kcl='kubectl config get-contexts --output name'
alias kctx='kubectl config current-context'
alias kcu='kubectl config unset current-context'
alias krew='kubectl krew'
alias stern='kubectl stern'

# [krename] rename all contexts with shorter names
krename() {
    local context
    kubectl config unset current-context &> /dev/null
    for context in $(kubectl config get-contexts --output name); do
        kubectl config rename-context "$context" "$(grep -o '[^_]*$' <<< "$context")"
    done
}

# [kcm] show configmaps; usage: kcm [-x|--context] [-n|--namespace] [configmap]
kcm() {
    local arg_ctx arg_ns arg_cm ctx ns configmap cm_key cmd; arg_cm="$1"
    local green='\033[0;32m' yellow='\033[0;33m' nc='\033[0m'
    zparseopts -E -D -- x:=arg_ctx -context:=arg_ctx n:=arg_ns -namespace:=arg_ns
    ctx="$(_k_ctx "${arg_ctx[2]}")"
    ns="$(_k_namespace "$ctx" "${arg_ns[2]}")"
    configmap="$(kubectl --context "$ctx" --namespace "$ns" get configmaps --output name \
        | grep "${arg_cm:-}" | _fzf_k --no-multi --delimiter '/' --with-nth 2)"
    while read -r cm_key; do
        cmd="kubectl --context $ctx --namespace $ns get $configmap --output json \
            | jq -r --arg key $cm_key '.data[\$key]'"
        echo -e "\n${green}${ctx}/${ns}/${configmap}/${key}${nc}\n\n${yellow}$(_save_and_exec "$cmd")${nc}\n"
    done <<< "$(kubectl --context $ctx --namespace $ns get $configmap --output json \
        | jq -r '.data|keys[]' | _fzf_k --multi)"
}

# [kcs] context set; usage: kcs [-x|--context]
kcs() {
    local arg_ctx ctx
    zparseopts -E -D -- x:=arg_ctx -context:=arg_ctx
    ctx="$(_k_ctx "${arg_ctx[2]}")"
    [[ -z "$ctx" ]] && return 1
    _save_and_exec "kubectl config set current-context $ctx"
}

# [kdebug] creates an ephemeral container for debugging; usage: kdebug [-x|--context] [-n|--namespace] [image]
kdebug() {
    local arg_ctx arg_ns ctx ns img; img="${1:-'ubuntu:rolling'}"
    zparseopts -E -D -- x:=arg_ctx -context:=arg_ctx n:=arg_ns -namespace:=arg_ns
    ctx="$(_k_ctx "${arg_ctx[2]}")"
    ns="$(_k_namespace "$ctx" "${arg_ns[2]}")"
    _save_and_exec "kubectl run --context $ctx --namespace $ns $(id -un)-debug --rm \
        --restart='Never' --stdin --tty --image=$img -- bash"
}

# [kex] execute command in container; usage: kex [-x|--context] [-n|--namespace] [-p|--pod] [-c|--container] [command]
kex() {
    local arg_ctx arg_ns arg_pod arg_container ctx ns pod container
    zparseopts -E -D -- \
        x:=arg_ctx -context:=arg_ctx \
        n:=arg_ns -namespace:=arg_ns \
        p:=arg_pod -pod:=arg_pod \
        c:=arg_container -container:=arg_container
    ctx="$(_k_ctx "${arg_ctx[2]}")"
    ns="$(_k_namespace "$ctx" "${arg_ns[2]}")"
    pod="$(_k_resource "$ctx" "$ns" pods "${arg_pod[2]}")"
    container="$(_k_container "$ctx" "$ns" "$pod" "${arg_container[2]}")"
    _save_and_exec "kubectl --context $ctx --namespace $ns exec --stdin --tty $pod --container $container -- $*"
}

# [klog] fetch log from container; usage: klog [-x|--context] [-n|--namespace] [-p|--pod] [-c|--container]
klog() {
    local arg_ctx arg_ns arg_pod arg_container ctx ns pod container
    zparseopts -E -D -- \
        x:=arg_ctx -context:=arg_ctx \
        n:=arg_ns -namespace:=arg_ns \
        p:=arg_pod -pod:=arg_pod \
        c:=arg_container -container:=arg_container
    ctx="$(_k_ctx "${arg_ctx[2]}")"
    ns="$(_k_namespace "$ctx" "${arg_ns[2]}")"
    pod="$(_k_resource "$ctx" "$ns" pods "${arg_pod[2]}")"
    container="$(_k_container "$ctx" "$ns" "$pod" "${arg_container[2]}")"
    _save_and_exec "kubectl --context $ctx --namespace $ns logs $pod --container $container"
}

# [kdb] export DB_* environment variables from K8s secrets; usage: kdb [-x|--context] [-n|--namespace]
kdb() {
    local arg_ctx arg_ns ctx ns secret
    zparseopts -E -D -- x:=arg_ctx -context:=arg_ctx n:=arg_ns -namespace:=arg_ns
    ctx="$(_k_ctx "${arg_ctx[2]}")"
    ns="$(_k_namespace "$ctx" "${arg_ns[2]}")"
    while read -r secret; do export "$secret"; done <<< "$(
        kubectl --context "$ctx" --namespace "$ns" get secrets --output json \
        | jq -jr '.items[1].data|with_entries(select(.key|match("DB_";"i")))|to_entries[]|"\(.key)=\(.value|@base64d)\n"')"
}

# [ksecret] base64 decrypt secrets; usage: ksecret [-x|--context] [-n|--namespace] [secret]
ksecret() {
    local arg_ctx arg_ns ctx ns secret key cmd
    local green='\033[0;32m' yellow='\033[0;33m' nc='\033[0m'
    zparseopts -E -D -- x:=arg_ctx -context:=arg_ctx n:=arg_ns -namespace:=arg_ns
    ctx="$(_k_ctx "${arg_ctx[2]}")"
    ns="$(_k_namespace "$ctx" "${arg_ns[2]}")"
    secret="$(kubectl --context "$ctx" --namespace "$ns" get secrets --output name | grep "${1:-}" | _fzf_k --no-multi)"
    while read -r key; do
        cmd="kubectl --context $ctx --namespace $ns get $secret --output json \
            | jq -r --arg key $key '.data[\$key]|@base64d'"
        echo -e "\n${green}${ctx}/${ns}/${secret}/${key}${nc}\n\n${yellow}$(_save_and_exec "$cmd")${nc}\n"
    done <<< "$(kubectl --context "$ctx" --namespace "$ns" get "$secret" --output json \
        | jq -r '.data|keys[]' | _fzf_k --multi)"
}

# [kwatch] watch a resource; usage: kwatch [-x|--context] [-n|--namespace] [kind]
kwatch() {
    local arg_ctx arg_ns ctx ns kind
    zparseopts -E -D -- x:=arg_ctx -context:=arg_ctx n:=arg_ns -namespace:=arg_ns
    ctx="$(_k_ctx "${arg_ctx[2]}")"
    ns="$(_k_namespace "$ctx" "${arg_ns[2]}")"
    kind="$(_k_api "$ctx" "$ns" "$1")"
    _save_and_exec "watch kubectl --context $ctx --namespace $ns get $kind"
}

# [khelp] show this help message
khelp() {
    echo "helper aliases and functions for kubectl"
    echo
    grep -E '^# \[.+\]' "${(%):-%x}"
}
