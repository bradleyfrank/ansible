#
# Wrappers around `virtualenv` to keep venvs centralized
# Author: Brad Frank
# Date: June 2024; Updated: March 2025
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


benv_get_venv_dir() {
  local git_toplevel benv_project

  if git_toplevel="$(git rev-parse --show-toplevel 2> /dev/null)"; then
    benv_project="$git_toplevel"
  else
    benv_project="$(pwd)"
  fi

  print "project_dir='$benv_project'"
  print "virtualenv='${VENVS_HOME}/$(md5sum <<< "$benv_project" | awk '{print $1}')'"
}


benv_get_project_dir() {
  realpath -P "${1}/project"
}


benv_get_all_venvs() {
  find "$VENVS_HOME" -maxdepth 1 -mindepth 1 -type d | sort
}


benv_msg() {
  local -A output
  local -r base03="%F{234}" cyan="%F{37}" yellow="%F{136}" blue="%F{33}" reset="%f"
  local msg virtualenv project_dir; msg="$1" virtualenv="$2" project_dir="$3"

  venv="$(dirname "$virtualenv")/$(basename "$virtualenv" | cut -b 1-4)…"

  output[prefix]="${base03}==>${yellow} ${msg}${reset}"
  output[venv]="${cyan}${venv/$HOME/~}${reset}"
  output[project]="${blue}${project_dir/$HOME/~}${reset}"

  print -P "${output[prefix]} :: ${output[venv]} -> ${output[project]}"
}


## ==============================================================================================
## Feature functions
## ----------------------------------------------------------------------------------------------

benv_activate() {
  local virtualenv project_dir requirements; eval "$(benv_get_venv_dir)"

  # Create the virtualenv if necessary
  if [[ ! -d "$virtualenv" ]]; then
    rm --recrusive --force "$virtualenv"
    mkdir --parents "${virtualenv}/venv"
    ln -s "$project_id" "{$virtualenv}/project"
    benv_msg "creating" "$virtualenv" "$project_dir"
    virtualenv --quiet "${virtualenv}/venv" "$@"
  fi

  benv_msg "activating" "$virtualenv" "$project_dir"
  source "${virtualenv}/venv/bin/activate"

  # Google Artifact Registry requires additional packages for authentication
  if python3 -m pip config get "global.index-url" 2>/dev/null \
    | trurl --get "{host}" --url-file - \
    | grep --quiet "pkg.dev"
  then
    benv_msg "authenticating" "$virtualenv" "$project_dir"

    pip install keyring keyrings.google-artifactregistry-auth \
      --index-url https://pypi.org/simple \
      --disable-pip-version-check \
      --require-virtualenv \
      --quiet

    if [[ "$(keyring --list-backends \
      | grep --extended-regex --count '(ChainerBackend|GooglePythonAuth)')" -ne 2 ]]
    then
      return 1
    fi
  fi

  requirements="$(find "$project_dir" -type f -name 'requirements.txt' -print -quit)"

  if [[ -n $requirements ]]; then
    benv_msg "syncing" "$virtualenv" "$project_dir"
    pip install --requirement "$requirements" --quiet
  fi

  pip install --upgrade pip --quiet
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
  local virtualenv project_dir; eval "$(benv_get_venv_dir)"
  [[ ! -d "$virtualenv" ]] && { print "No virtualenv for this project." >&2; return 1; }
  benv_msg "virtualenv" "$virtualenv" "$project_dir"
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
        --preview='realpath -P {}/project' --preview-window 'down')"
  else
    projects="$(for project in $(benv_get_all_venvs); do basename "$project"; done | xargs)"
    match="$(sed 's/[^a-f0-9]/|/g' <<< "$match")"  # convert input to regex
    projects="$(grep -Eo "\b(${match})[a-f0-9]+\b" <<< "$projects" \
      | xargs -I{} echo "${VENVS_HOME}/{}")"
  fi

  if [[ -z $projects ]]; then
    return 0
  fi

  while read -r project; do
    benv_msg "removing" "${project}" "$(benv_get_project_dir "$project")"
    rm -rf "$project"
  done <<< "$projects"
}


benv() {
  local subcmd; subcmd="$1"
  [[ "$#" -ge 1 ]] && shift
  case "$subcmd" in
    in|activate) benv_activate "$@" ;;
    out|deactivate) deactivate ;;
    clean|cleanup) benv_cleanup ;;
    info|show) benv_info ;;
    list|ls) benv_list ;;
    delete|remove|rm) benv_remove "$@" ;;
    *) benv_usage ;;
  esac
}
