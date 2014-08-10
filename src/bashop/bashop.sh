#!/usr/bin/env bash

bashop::check_dependencies() {
  local req_version='4.0.0'

  if !(bashop::utils::check_version ${req_version} ${BASH_VERSION}); then
    local msg="Your version of bash is to low. Minimum required is '${req_version}', "
    msg+=", yours is '${BASH_VERSION}'"

    bashop::logger::error "${msg}"
    exit 1
  fi
}

bashop::start() {
  bashop::app::start "${@}"
}

bashop::check_dependencies