#!/usr/bin/env bash
set -euo pipefail

# Helper functions to solve paths
bashop::resolve_link() {
  $(type -p greadlink readlink | head -1) "${1}"
}

bashop::abs_dirname() {
  local cwd="$(pwd)"
  local path="${1}"

  while [ -n "${path}" ]; do
    cd "${path%/*}"
    local name="${path##*/}"
    path="$(bashop::resolve_link "${name}" || true)"
  done

  pwd
  cd "${cwd}"
}

# Set needed paths
readonly _BASHOP_ROOT="$(bashop::abs_dirname "${BASH_SOURCE[0]}")"
readonly _BASHOP_APP_ROOT="$(bashop::abs_dirname "${0}")"
readonly _BASHOP_APP_COMMAND_ROOT="${_BASHOP_APP_ROOT}/commands"

# Include files
source "${_BASHOP_ROOT}/utils/functions.sh"
source "${_BASHOP_ROOT}/utils/echo.sh"
source "${_BASHOP_ROOT}/utils/run_process.sh"
source "${_BASHOP_ROOT}/utils/argument_parser.sh"

if (bashop::function_exists "bashop::init"); then
  bashop::init
fi

# Execute command
_BASHOP_COMMAND=()
command="${1}"

case "${command}" in
  "" | "-h" | "--help" )
    #exec help
    ;;
  * )
    command_path="${_BASHOP_APP_COMMAND_ROOT}/${command}"

    if [[ ! -f "${command_path}" ]]; then
      bashop::echo_fail "no such command \`${command}'\n" >&2
      exit 1
    fi

    source "${command_path}"
    _BASHOP_COMMAND+=(${command})
    bashop::parse_arguments ${@}

    if (bashop::function_exists "bashop::run_command"); then
      bashop::run_command
    else
      bashop::echo_framework_error "Every command must define the function bashop::run_command"
    fi

    ;;
esac

if (bashop::function_exists "bashop::destroy"); then
  bashop::destroy
fi