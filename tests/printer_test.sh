#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/../src/bashop/modules/printer.sh
source ${DIR}/../src/bashop/modules/utils.sh

function check_echo() {
  #Should be 'test\n' but last \n will be removed from bash, so that should be also ok
  local string=$(bashop::printer::echo "test")
  assertion__equal $'test' "${string}"

  string=$(bashop::printer::echo "test" "!")
  assertion__equal "test!" "${string}"

  string=$(bashop::printer::echo "test" false)
  assertion__equal "test" "${string}"
}

function check_info() {
  local test_string=$'\033[00;34mInfo: test\n\033[0m'
  local fnc_string=$(bashop::printer::info "test")
  assertion__equal "${test_string}" "${fnc_string}"

  test_string=$'\033[00;34mInfo: test!\033[0m'
  fnc_string=$(bashop::printer::info "test" "!")
  assertion__equal "${test_string}" "${fnc_string}"

  test_string=$'\033[00;34mInfo: test\033[0m'
  fnc_string=$(bashop::printer::info "test" false)
  assertion__equal "${test_string}" "${fnc_string}"
}

function check_user() {
  local test_string=$'\033[00;33mtest\n\033[0m'
  local fnc_string=$(bashop::printer::user "test")
  assertion__equal "${test_string}" "${fnc_string}"

  test_string=$'\033[00;33mtest!\033[0m'
  fnc_string=$(bashop::printer::user "test" "!")
  assertion__equal "${test_string}" "${fnc_string}"

  test_string=$'\033[00;33mtest\033[0m'
  fnc_string=$(bashop::printer::user "test" false)
  assertion__equal "${test_string}" "${fnc_string}"
}

function check_success() {
  local test_string=$'\033[00;32mtest\n\033[0m'
  local fnc_string=$(bashop::printer::success "test")
  assertion__equal "${test_string}" "${fnc_string}"

  test_string=$'\033[00;32mtest!\033[0m'
  fnc_string=$(bashop::printer::success "test" "!")
  assertion__equal "${test_string}" "${fnc_string}"

  test_string=$'\033[00;32mtest\033[0m'
  fnc_string=$(bashop::printer::success "test" false)
  assertion__equal "${test_string}" "${fnc_string}"
}

function check_error() {
  local test_string=$'\033[00;31mError: test\n\033[0m'
  local fnc_string=$(bashop::printer::error "test")
  assertion__equal "${test_string}" "${fnc_string}"

  test_string=$'\033[00;31mError: test!\033[0m'
  fnc_string=$(bashop::printer::error "test" "!")
  assertion__equal "${test_string}" "${fnc_string}"

  test_string=$'\033[00;31mError: test\033[0m'
  fnc_string=$(bashop::printer::error "test" false)
  assertion__equal "${test_string}" "${fnc_string}"
}

function check_verbose() {
  local test_string=$'\033[00;34mtest\n\033[0m'
  local fnc_string=$(bashop::printer::verbose "test")
  assertion__string_empty "${fnc_string}"

  declare -g _BASHOP_VERBOSE=false
  fnc_string=$(bashop::printer::verbose "test")
  assertion__string_empty "${fnc_string}"

  _BASHOP_VERBOSE=true
  fnc_string=$(bashop::printer::verbose "test")
  assertion__equal "${test_string}" "${fnc_string}"

  test_string=$'\033[00;34mtest!\033[0m'
  fnc_string=$(bashop::printer::verbose "test" "!")
  assertion__equal "${test_string}" "${fnc_string}"

  test_string=$'\033[00;34mtest\033[0m'
  fnc_string=$(bashop::printer::verbose "test" false)
  assertion__equal "${test_string}" "${fnc_string}"
}

function check_framework_error() {
  local fnc_string=$(bashop::printer::__framework_error "test")

  assertion__string_contains "${fnc_string}" $'FRAMEWORK ERROR: test\n'
  assertion__string_contains "${fnc_string}" $'\033[00;31m'
  assertion__string_contains "${fnc_string}" $'\033[0m'
}

function check_help_formater() {
  #Should be '  func   desc1\n  func2  desc2\n' but last '\n' will be removed from bash, so that should be also ok
  local test_string=''
  test_string+=$'  func   desc1\n'
  test_string+=$'  func2  desc2'

  local array=(
    "func  desc1"
    "func2  desc2"
  )

  local fnc_string=$(bashop::printer::help_formater array[@])
  assertion__equal "${test_string}" "${fnc_string}"


  array+=( "wrongfunc wrong_desc" )

  local fnc_string=$(bashop::printer::help_formater array[@])
  assertion__string_contains "${fnc_string}" "FRAMEWORK ERROR: Wrong syntax"
}