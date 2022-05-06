#
# Manages virtualenvs and can install pip requirements.
# Author: Brad Frank
# Date: Oct 2021
# Tested: zsh 5.8 (x86_64-apple-darwin19.6.0)
#

pyenv() {
  _pyenv_usage() {
    echo "Usage: pyenv -c(reate) [version] | -a(ctivate) | -d(eactivate) | -p(ip install requirements)"
  }

  _pyenv_get_ve() {
    dirname "$(find . -maxdepth 2 -type f -name pyvenv.cfg)"
  }

  _pyenv_create() {
    local version; version="$1"
    if [[ -z $version ]]; then version=$(python3 --version | grep -Po '3\.\d+'); fi
    if [[ -d ve ]]; then return 0; else virtualenv -p "$version" ve; fi
  }

  _pyenv_activate() {
    #shellcheck disable=SC1091
    source "$(_pyenv_get_ve)/bin/activate"
  }

  _pyenv_pip() {
    if [[ -z "$VIRTUAL_ENV" ]]; then _pyenv_activate; fi
    if [[ -f requirements.txt ]]; then
      "$(_pyenv_get_ve)/bin/pip" install -r requirements.txt
    fi
  }

  case "$1" in
        -c|--create) _pyenv_create "$2" ;;
      -a|--activate) _pyenv_activate ;;
           -p|--pip) _pyenv_pip ;;
    -d|--deactivate) deactivate ;;
          -h|--help) _pyenv_usage ;;
                  *) _pyenv_usage; return 1 ;;
  esac

  return $?
}
