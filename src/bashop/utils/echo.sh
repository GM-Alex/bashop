#!/usr/bin/env bash

bashop::echo() {
  #TODO
  local string_to_print=${1}
  while [[ ${#string_to_print} -gt 40 ]]; do
    string_to_print='a'
  done
}

bashop::echo_info() {
  printf "\033[00;34m${1}\033[0m"
}

bashop::echo_user() {
  printf "\033[0;33m${1}\033[0m"
}

bashop::echo_success() {
  printf "\033[00;32m${1}\033[0m"
}

bashop::echo_fail() {
  printf "\033[00;31m${1}\033[0m"
}

bashop::echo_framework_error() {
  local framework_error="If you are a user and not the programmer of this application please contact the developter"
  framework_error+="and send him the following message as error report:\n\n${1}\n"
  printf "\033[00;31m${framework_error}\033[0m"
}