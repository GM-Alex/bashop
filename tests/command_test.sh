#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/../src/bashop/modules/utils.sh
source ${DIR}/../src/bashop/modules/printer.sh
source ${DIR}/../src/bashop/modules/command.sh

function check_show_help() {
  #TODO
  local func_string=''
}

function check_parse_arguments() {
  mock__make_function_do_nothing "bashop::printer::framework_error"
  mock__make_function_do_nothing "bashop::printer::error"

  local command=( "command" "subcom" )
  local command_arguments=( "--test" "-z" "<name>" "<version>" "[<extra>...]" )
  local command_options=(
    "-o  An optional short option."
    "--option  An optional long option."
    "--repeatable...  A repeatable option."
    "-o, --optional-opt  An optional option with shortcut."
    "-r..., --repeatable-opt...  A repeatable option with shortcut."
    "-a ARG, --argument-opt=<arg>  A required option with optional argument [default: test]."
    "-b... <arg>, --repeatable-argument-opt...=<arg>  A required option with requrired argument."
    "-c... SARG --output...=<arg>  Aaaa [default: test]."
    "-d <sarg> --dee LARG  Aaaa [default: test]."
  )

  local raw_arguments=( "cmd" )

  (bashop::command::parse_arguments command[@] command_arguments[@] command_options[@] raw_arguments[@])
  assertion__status_code_is_failure $?

  raw_arguments=( "wrong_command" "subcom" "name" "version" )

  (bashop::command::parse_arguments command[@] command_arguments[@] command_options[@] raw_arguments[@])
  assertion__status_code_is_failure $?

  raw_arguments=( "command" "wrong_subcom" "name" "version" )

  (bashop::command::parse_arguments command[@] command_arguments[@] command_options[@] raw_arguments[@])
  assertion__status_code_is_failure $?

  raw_arguments=( "command" "subcom" "name" "version" )

  (bashop::command::parse_arguments command[@] command_arguments[@] command_options[@] raw_arguments[@])
  assertion__status_code_is_success $?

  raw_arguments=( "command" "subcom" "name" "version" "--option" )

  (bashop::command::parse_arguments command[@] command_arguments[@] command_options[@] raw_arguments[@])
  assertion__status_code_is_success $?

  raw_arguments=( "command" "subcom" "name" "version" "--option" "--option" )

  (bashop::command::parse_arguments command[@] command_arguments[@] command_options[@] raw_arguments[@])
  assertion__status_code_is_failure $?
}
