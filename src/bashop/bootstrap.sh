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

##########################################
# Source the commands for the command dir
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
##########################################
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

# Set needed paths
readonly BASHOP_ROOT="$(bashop::abs_dirname "${BASH_SOURCE[0]}")"
readonly BASHOP_APP_ROOT="$(bashop::abs_dirname "${0}")"
readonly BASHOP_APP_COMMAND_ROOT="${BASHOP_APP_ROOT}/commands"

# Set global vars
source "${BASHOP_ROOT}/modules/globals.sh"

# Set default options
readonly _BASHOP_BUILD_IN_OPTIONS=(
    "-h --help  Shows this help"
    "-v --version  Shows the version information"
    "--verbose  Shows more detailed information"
)

# Include files
source "${BASHOP_ROOT}/modules/utils.sh"
source "${BASHOP_ROOT}/modules/printer.sh"
source "${BASHOP_ROOT}/modules/bashop.sh"
source "${BASHOP_ROOT}/modules/config.sh"
bashop::include_commands
source "${BASHOP_ROOT}/modules/app.sh"
source "${BASHOP_ROOT}/modules/command.sh"

bashop::start "${@}"