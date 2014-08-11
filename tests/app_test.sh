#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/../src/bashop/modules/utils.sh
source ${DIR}/../src/bashop/modules/printer.sh
source ${DIR}/../src/bashop/modules/app.sh

function check_show_help() {
  #TODO mock commands
  readonly _BASHOP_BUILD_IN_OPTIONS=(
    "-h --help  Shows this help"
    "-v --verbose  Shows more detailed information"
  )

  local test_string=''
  test_string+=$'Usage:\n'
  test_string+=$'  testapp <command> [options] <arguments>\n\n'
  test_string+=$'Commands:\n'
  test_string+=$'  com         The example command\n'
  test_string+=$'  com subcom  A command with one option\n\n'
  test_string+=$'Options:\n'
  test_string+=$'  -h --help     Shows this help\n'
  test_string+=$'  -v --verbose  Shows more detailed information'

  local func_string="$(bashop::app::show_help "testapp")"

  assertion__equal "${test_string}" "${func_string}"
}

function check_start() {
  #TODO
  local func_string=''
}

function global_setup() {
  BASHOP_APP_COMMAND_ROOT=${DIR}/../example/commands
}