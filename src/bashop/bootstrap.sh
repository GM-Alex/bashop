#!/usr/bin/env bash
set -euo pipefail

# Helper functions to solve paths
resolve_link() {
  $(type -p greadlink readlink | head -1) "$1"
}

abs_dirname() {
  local cwd="$(pwd)"
  local path="$1"

  while [ -n "$path" ]; do
    cd "${path%/*}"
    local name="${path##*/}"
    path="$(resolve_link "$name" || true)"
  done

  pwd
  cd "$cwd"
}

# Set needed paths
export _BASHOP_ROOT="$(abs_dirname "${BASH_SOURCE[0]}")"
source ${_BASHOP_ROOT}/utils/functions.sh
source ${_BASHOP_ROOT}/utils/echo.sh
source ${_BASHOP_ROOT}/utils/run_process.sh
source ${_BASHOP_ROOT}/utils/argument_parser.sh

export _BASHOP_APP_ROOT="$(abs_dirname "$0")"
export _BASHOP_APP_COMMAND_ROOT="${_BASHOP_APP_ROOT}/commands"
export PATH="${_BASHOP_APP_COMMAND_ROOT}:$PATH"

# Execute command
command="$1"
full_args=${@}
case "$command" in
"" | "-h" | "--help" )
  #exec help
  ;;
* )
  command_path="$(command -v "$command" || true)"

  if [ ! -x "$command_path" ]; then
    echo_fail "no such command \`$command'\n" >&2
    exit 1
  fi

  shift
  source "$command_path"
  parse_arguments ${full_args}
  _run
  ;;
esac