#!/usr/bin/env zsh

#
# Functions for making gcloud easier to use.
# Author: Brad Frank
# Date: Feb 2022
# Tested: zsh 5.8 (x86_64-apple-darwin19.6.0)
# Requires: gcloud, fzf
#

_fzf_g() { fzf --select-1 --exit-0 --ansi -i --height=50% --reverse --inline-info --border rounded "$@"; }

_gc_project() {
    gcloud projects list --format="value(name,projectId)" | grep "${1:-}" \
        | _fzf_g --no-multi --delimiter '\t' --with-nth 1 | awk '{print $2}'
}

_save_and_exec() {
    local cmd; cmd="$(tr -s ' ' <<< "$1")"
    fc -R =(echo "$cmd")
    eval "$cmd"
}

alias gpu='gcloud config unset project'


# [gpl] list gcloud projects;  usage: gpl [-c|--columns <columns>] [-f|--filter <filter>]
gpl() {
    local columns filter default_columns default_filter
    default_columns="name,projectId,projectNumber"
    default_filter="projectId !~ \"^(sys|quickstart|test|gam)-.*\""
    zparseopts -E -D -- c:=columns -columns:=columns f:=filter -filter:=filter
    gcloud projects list \
      --sort-by="name" \
      --format="value(${columns:-${default_columns}})" \
      --filter="${filter:-${default_filter}}" \
      | column -ts $'\t'
}


# [gkube] generate kubectl credentials
gkube() {
    local project cluster
    mv "$HOME"/.kube/config "$HOME"/.kube/config."$(date --iso-8601=seconds | tr -d ':-')"

    while read -r project; do
        while read -r cluster; do
            [[ -z "$cluster" ]] && continue
            _save_and_exec "gcloud container clusters get-credentials \
                $(awk '{print $2}' <<< "$cluster") \
                --region=$(awk '{print $1}' <<< "$cluster") \
                --project $project"
        done < <(gcloud container clusters list \
            --project "$project" \
            --format="value[separator=' '](zone,name)" \
            | _fzf_g --multi --delimiter ' ' --with-nth 2)
    done < <(gpl --columns="projectId" | _fzf_g --multi)
}


# [gssh] allows you to ssh into a GCS instance;  usage: gssh [-p|--project]
gssh() {
    local project _project
    zparseopts -E -D -- p:=project -project:=project
    _project="$(_gc_project "${project[2]}")"
    ssh "$(gcloud --project "$_project" compute instances list \
        --format="value[separator=' '](name,networkInterfaces[0].networkIP)" \
        | _fzf_g --no-multi --delimiter " " --with-nth 1 \
        | awk '{print $2}'
    )"
}


# [ghelp] show this help message
ghelp() {
    echo "helper aliases and functions for gcloud SDK"
    echo
    grep -E '^# \[.+\]' "${(%):-%x}"
}
