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
  printf "\033[00;34m"
  bashop::logger::echo "${1}" "${@:2}"
  printf "\033[0m"
}

bashop::logger::user() {
  printf "\033[0;33m"
  bashop::logger::echo "${1}" "${@:2}"
  printf "\033[0m"
}

bashop::logger::success() {
  printf "\033[00;32m"
  bashop::logger::echo "${1}" "${@:2}"
  printf "\033[0m"
}

bashop::logger::error() {
  printf "\033[00;31m"
  bashop::logger::echo "Error: ${1}" "${@:2}"
  printf "\033[0m"
}

bashop::logger::framework_error() {
  local msg=''
  msg+="It's not your fault... expect you are the developer of this application or worse "
  msg+="you are the user and changed something, than congratulations you broke it ;). "
  msg+="If you are a user and you didn't done something then please send the developer "
  msg+="of this application the following message as error report:\n\nFRAMEWORK ERROR: ${1}"

  printf "\033[00;31m"
  bashop::logger::echo "${msg}" "${@:2}"
  printf "\033[0m"
}