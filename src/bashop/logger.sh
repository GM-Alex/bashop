#!/usr/bin/env bash

bashop::logger::echo() {
  printf "${1}"

  if ! [[ -n ${2+1} ]]; then
    printf "\n"
  elif [[ ${2} != false ]]; then
    printf "${2}"
  fi

  #TODO
  #local string_to_print=${1}
  #while [[ ${#string_to_print} -gt 40 ]]; do
  #  string_to_print='a'
  #done
}

bashop::logger::info() {
  bashop::logger::echo "\033[00;34m${1}\033[0m" "${*:2}"

  if ! [[ -n ${2+1} ]]; then
    printf "\n"
  fi
}

bashop::logger::user() {
  bashop::logger::echo "\033[0;33m${1}\033[0m" "${*:2}"
}

bashop::logger::success() {
  bashop::logger::echo "\033[00;32m${1}\033[0m" "${*:2}"
}

bashop::logger::error() {
  bashop::logger::echo "\033[00;31m${1}\033[0m" "${*:2}"
}

bashop::logger::framework_error() {
  local msg=''
  msg+="It's not your fault... expect you are the developer of this application. If you are a user "
  msg+="please send the developer the following message as error report:\n${1}"

  bashop::logger::echo "\033[00;31m${msg}\033[0m" "${*:2}"
}