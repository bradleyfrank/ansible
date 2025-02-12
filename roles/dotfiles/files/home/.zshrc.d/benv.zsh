#
# Wrappers around `virtualenv` to keep venvs centralized
# Author: Brad Frank
# Date: June 2024
# Tested: zsh 5.9 (arm-apple-darwin23.0.0)
# Requires: virtualenv, git, fzf, md5sum, trurl
#


## ==============================================================================================
## Usage functions
## ----------------------------------------------------------------------------------------------

benv_usage() {
  local -A options

  options=(
    ['activate|a8']="Activate the virtualenv for the current directory"
    ['deactivate|da8|envout']="Deactivate the virtualenv"
    ['sync|update|envin']="Activate and install packages from 'requirements.txt'"
    ['clean|cleanup']="Remove broken/abandonded virtualenvs"
    ['info|show']="Show path to virtualenv"
    ['list|ls']="List all virtualenvs"
    ['delete|remove|rm']="Remove one or more virtualenvs"
    ['help']="Show this help message"
  )

  print "benv: Manage virtualenvs for Python"
  for option desc in "${(@kv)options}"; do
    print "  ${option};${desc}"
  done | column -ts ';'
}


## ==============================================================================================
## Helper functions
## ----------------------------------------------------------------------------------------------

export VENVS_HOME="${HOME}/.local/share/venvs"

a8() { benv_activate; }
da8() { benv_deactivate; }
envin() { benv_activate; benv_sync; }
envout() { benv_deactivate; }


benv_get_venv_dir() {
  local git_toplevel md5 benv_project; benv_project="$(pwd)"
  git_toplevel="$(git rev-parse --show-toplevel 2> /dev/null)" && benv_project="$git_toplevel"
  md5="$(md5sum <<< "$benv_project" | awk '{print $1}')"
  print "${VENVS_HOME}/${md5}"
}


benv_get_project_dir() {
  realpath -P "${1:-$VIRTUAL_ENV_PROJECT}/project"
}


benv_get_all_venvs() {
  find "$VENVS_HOME" -maxdepth 1 -mindepth 1 -type d | sort
}


benv_msg() {
  local -A output
  local -r base03="%F{234}" cyan="%F{37}" yellow="%F{136}" blue="%F{33}" reset="%f"
  local msg venv project; msg="$1" venv="$2" project="$3"

  [[ -z $project ]] && project="$(benv_get_project_dir)"
  venv="$(dirname "$venv")/$(basename "$venv" | cut -b 1-4)…"

  output[prefix]="${base03}==>${yellow} ${msg}${reset}"
  output[venv]="${cyan}${venv/$HOME/~}${reset}"
  output[project]="${blue}${project/$HOME/~}${reset}"

  print -P "${output[prefix]} :: ${output[venv]} -> ${output[project]}"
}


benv_gar_auth() {
  local index_url domain backends

  index_url="$(python3 -m pip config get "global.index-url" 2>/dev/null)" || return 0
  domain="$(trurl --get "{host}" "$index_url")"
  grep --quiet "pkg.dev" <<< "$domain" || return 0

  benv_msg "authenticating" "$VIRTUAL_ENV_PROJECT"
  pip install keyring keyrings.google-artifactregistry-auth \
    --index-url https://pypi.org/simple \
    --disable-pip-version-check \
    --require-virtualenv \
    --quiet

  backends="$(keyring --list-backends \
    | grep --extended-regex --count '(ChainerBackend|GooglePythonAuth)')"
  case "$backends" in (2) return 0 ;; (*) return 1 ;; esac
}


## ==============================================================================================
## Feature functions
## ----------------------------------------------------------------------------------------------

benv_deactivate() {
  unset VIRTUAL_ENV_PROJECT
  deactivate
}


benv_activate() {
  [[ -z $VIRTUAL_ENV_PROJECT ]] && export VIRTUAL_ENV_PROJECT="$(benv_get_venv_dir)"
  [[ ! -d "$VIRTUAL_ENV_PROJECT" ]] && benv_create "$@"
  benv_msg "activating" "$VIRTUAL_ENV_PROJECT"
  source "${VIRTUAL_ENV_PROJECT}/venv/bin/activate"
  benv_gar_auth
}


benv_create() {
  [[ -z $VIRTUAL_ENV_PROJECT ]] && export VIRTUAL_ENV_PROJECT="$(benv_get_venv_dir)"
  if [[ ! -e "$VIRTUAL_ENV_PROJECT" ]]; then
    mkdir --parents "${VIRTUAL_ENV_PROJECT}/venv"
    pushd "$VIRTUAL_ENV_PROJECT" > /dev/null || return 1
    ln -s "$(dirs -lp | tail -n1)" project
    popd > /dev/null || return 1
    benv_msg "creating" "$VIRTUAL_ENV_PROJECT"
    virtualenv --quiet "${VIRTUAL_ENV_PROJECT}/venv" "$@"
  fi
}


benv_sync() {
  local requirements
  [[ -z $VIRTUAL_ENV ]] && return 1
  requirements="$(find . -maxdepth 2 -type f -name 'requirements.txt' -print -quit)"
  benv_msg "syncing" "$VIRTUAL_ENV_PROJECT"
  [[ -z $requirements ]] && return 0
  pip install -r "$requirements" > /dev/null
}


benv_cleanup() {
  local project
  while read -r project; do
    if [[ ! -L "${project}/project" || ! -d "$(realpath -P "${project}/project")" ]]; then
      benv_msg "removing" "${project}" "(missing project)"
      rm -rf "$project"
    fi
  done <<< "$(benv_get_all_venvs)"
}


benv_info() {
  local benv_dir
  benv_dir="$(benv_get_venv_dir)"
  [[ ! -d "$benv_dir" ]] && { print "No virtualenv for this project." >&2; return 1; }
  benv_msg "virtualenv" "$VIRTUAL_ENV_PROJECT"
}


benv_list() {
  local project
  while read -r project; do
    [[ ! -L "${project}/project" ]] && continue
    benv_msg "virtualenv" "${project}" "$(benv_get_project_dir "$project")"
  done <<< "$(benv_get_all_venvs)"
}


benv_remove() {
  local projects project match; match="$@"

  if [[ "$#" -eq 0 ]]; then
    projects="$(benv_get_all_venvs | fzf-tmux -p --multi \
        --delimiter / --with-nth -1 \
        --preview='realpath -P {}/project' --preview-window 'down'
    )"
  else
    projects="$(for project in $(benv_get_all_venvs); do basename "$project"; done | xargs)"
    match="$(sed 's/[^a-f0-9]/|/g' <<< "$match")"  # convert input to regex
    projects="$(grep -Eo "\b(${match})[a-f0-9]+\b" <<< "$projects" \
      | xargs -I{} echo "${VENVS_HOME}/{}")"
  fi

  [[ -z $projects ]] && return 0

  while read -r project; do
    benv_msg "removing" "${project}" "$(benv_get_project_dir "$project")"
    rm -rf "$project"
  done <<< "$projects"
}


## ==============================================================================================
## Main program
## ----------------------------------------------------------------------------------------------

benv() {
  local subcmd; subcmd="$1"
  [[ "$#" -ge 1 ]] && shift
  case "$subcmd" in
    a8|activate) benv_activate "$@" ;;
    da8|deactivate) benv_deactivate ;;
    sync|update) benv_sync "$@" ;;
    clean|cleanup) benv_cleanup ;;
    info|show) benv_info ;;
    list|ls) benv_list ;;
    delete|remove|rm) benv_remove "$@" ;;
    *) benv_usage ;;
  esac
}
