#!/usr/bin/env bash
set -euo pipefail

##########################################
# Helper functions to solve paths
# Globals:
#   None
# Arguments:
#   string path
# Returns:
#   string
##########################################
bashop::resolve_link() {
  $(type -p greadlink readlink | head -1) "${1}"
}

##########################################
# Return the absolute dir name
# Globals:
#   None
# Arguments:
#   string path
# Returns:
#   string
##########################################
bashop::abs_dirname() {
  local cwd="$(pwd)"
  local path="${1}"

  while [[ -n "${path}" ]]; do
    cd "${path%/*}"
    local name="${path##*/}"
    path="$(bashop::resolve_link "${name}" || true)"
  done

  pwd
  cd "${cwd}"
}

bashop::include_commands() {
  if [[ -d ${BASHOP_APP_COMMAND_ROOT} ]]; then
    local command
    local commands=( ${BASHOP_APP_COMMAND_ROOT}/* )

    for command in "${commands[@]}"; do
      source ${command}
      _BASHOP_KNOWN_COMMANDS+=( ${command##*/} )
    done
  fi
}

# Default vars
declare -g -A args=()
declare -g _BASHOP_VERBOSE=false
declare -g -a _BASHOP_KNOWN_COMMANDS=()

# Set needed paths
readonly BASHOP_ROOT="$(bashop::abs_dirname "${BASH_SOURCE[0]}")"
readonly BASHOP_APP_ROOT="$(bashop::abs_dirname "${0}")"
readonly BASHOP_APP_COMMAND_ROOT="${BASHOP_APP_ROOT}/commands"

# Set default options
readonly _BASHOP_BUILD_IN_OPTIONS=(
    "-h --help  Shows this help"
    "-v --verbose  Shows more detailed information"
)

# Include files
source "${BASHOP_ROOT}/modules/utils.sh"
source "${BASHOP_ROOT}/modules/printer.sh"
source "${BASHOP_ROOT}/modules/bashop.sh"
bashop::include_commands
source "${BASHOP_ROOT}/modules/app.sh"
source "${BASHOP_ROOT}/modules/command.sh"

bashop::start "${@}"