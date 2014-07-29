#!/usr/bin/env bash
set -euo pipefail

# Helper functions to solve paths
bashop::resolve_link() {
  $(type -p greadlink readlink | head -1) "${1}"
}

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

# Set needed paths
readonly _BASHOP_ROOT="$(bashop::abs_dirname "${BASH_SOURCE[0]}")"
readonly _BASHOP_APP_ROOT="$(bashop::abs_dirname "${0}")"
readonly _BASHOP_APP_COMMAND_ROOT="${_BASHOP_APP_ROOT}/commands"

# Include files
source "${_BASHOP_ROOT}/utils.sh"
source "${_BASHOP_ROOT}/logger.sh"
source "${_BASHOP_ROOT}/command.sh"
source "${_BASHOP_ROOT}/app.sh"

bashop::app::start "${@}"