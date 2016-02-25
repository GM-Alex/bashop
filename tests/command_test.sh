#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/../src/bashop/modules/utils.sh
source ${DIR}/../src/bashop/modules/printer.sh
source ${DIR}/../src/bashop/modules/command.sh

function check_show_help() {
  local test_string=''
  test_string+=$'Usage:\n'
  test_string+=$'  app command [options] <firstarg> <secondarg>\n\n'
  test_string+=$'Options:\n'
  test_string+=$'  -a                               Short option.\n'
  test_string+=$'  -b ARG                           Short option with arg style one.\n'
  test_string+=$'  -k... ARG, --koption... ARG      Repeatable short and long option with arg style one.\n'
  test_string+=$'  -l... <arg>, --loption...=<arg>  Repeatable short and long option with arg style two [default: test].'


  local command_with_app_name=(
    "app"
    "command"
  )
  local command_arguments=(
    "<firstarg> <secondarg>"
  )
  local command_options=(
    "-a  Short option."
    "-b ARG  Short option with arg style one."
    "-k... ARG, --koption... ARG  Repeatable short and long option with arg style one."
    "-l... <arg>, --loption...=<arg>  Repeatable short and long option with arg style two [default: test]."
  )

  local func_string="$(bashop::command::__show_help command_with_app_name[@] command_arguments[@] command_options[@])"
  assertion__equal "${test_string}" "${func_string}"
}

function check_parse_arguments() {
  # Valid config
  local command=( "command" "subcom" )
  local command_arguments=( "-z" "--zoption" "<name>" "<version>" "[<extra>...]" )
  local command_options=(
    "-a  Short option."
    "-b ARG  Short option with arg style one."
    "-c <arg>  Short option with arg style two."
    "-d...  Repeatable short option."
    "-e... ARG  Repeatable short option with arg style one."
    "-f... <arg>  Repeatable short option with arg style two [default: test]."
    "--aoption  Long option."
    "--boption ARG  Long option with arg style one."
    "--coption=<arg>  Long option with arg style two."
    "--doption...  Repeatable Long option."
    "--eoption... ARG  Repeatable Long option with arg style one [default: test]."
    "--foption...=<arg>  Repeatable Long option with arg style two."
    "-g, --goption  Short and long option."
    "-h ARG, --hoption ARG  Short and long option with arg style one."
    "-i <arg>, --ioption=<arg>  Short and long option with arg style two."
    "-j..., --joption...  Repeatable Short and long option."
    "-k... ARG, --koption... ARG  Repeatable short and long option with arg style one."
    "-l... <arg>, --loption...=<arg>  Repeatable short and long option with arg style two [default: test]."
  )
  local raw_arguments=( )

  # --- Test invalid config ---

  # Invalid command arguments
  local invalid_command_arguments=( "<name>" "<version>..." "[<extra>...]" )
  fnc_string=$(bashop::command::__parse_arguments command[@] invalid_command_arguments[@] command_options[@] raw_arguments[@])
  assertion__string_contains "${fnc_string}" "FRAMEWORK ERROR: Only the last argument can be repeatable"


  raw_arguments=( "wrong_command" "subcom" "name" "version" )
  fnc_string=$(bashop::command::__parse_arguments command[@] command_arguments[@] command_options[@] raw_arguments[@])
  assertion__string_contains "${fnc_string}" "FRAMEWORK ERROR: Unknown command 'wrong_command' called"

  raw_arguments=( "command" "wrong_subcom" "name" "version" )
  fnc_string=$(bashop::command::__parse_arguments command[@] command_arguments[@] command_options[@] raw_arguments[@])
  assertion__string_contains "${fnc_string}" "FRAMEWORK ERROR: Unknown command 'wrong_subcom' called"

  # Invalid command options
  local invalide_command_options=(
    "--a  Short option."
  )
  fnc_string=$(bashop::command::__parse_arguments command[@] command_arguments[@] invalide_command_options[@] raw_arguments[@])
  assertion__string_contains "${fnc_string}" "FRAMEWORK ERROR: Wrong pattern for option '--a  Short option.'"

  invalide_command_options=(
    "-a..., --aoption  Desc."
  )
  fnc_string=$(bashop::command::__parse_arguments command[@] command_arguments[@] invalide_command_options[@] raw_arguments[@])
  assertion__string_contains "${fnc_string}" "FRAMEWORK ERROR: One of the option of '-a..., --aoption  Desc.' is repeatable so both must be repeatable."

  invalide_command_options=(
    "-a ARG, --aoption  Desc."
  )
  fnc_string=$(bashop::command::__parse_arguments command[@] command_arguments[@] invalide_command_options[@] raw_arguments[@])
  assertion__string_contains "${fnc_string}" "FRAMEWORK ERROR: One of the option of '-a ARG, --aoption  Desc.' accepts an argument so both must accept one."


  # --- Test for user input ---

  # Test commands

  raw_arguments=( "command" "subcom" "name" "version" )
  (bashop::command::__parse_arguments command[@] command_arguments[@] command_options[@] raw_arguments[@])
  assertion__status_code_is_success $?


  # Test options

  raw_arguments=( "command" "subcom" "name" "version" "--option" )
  fnc_string=$(bashop::command::__parse_arguments command[@] command_arguments[@] command_options[@] raw_arguments[@])
  assertion__string_contains "${fnc_string}" "Error: Unkown option '--option'"

  raw_arguments=( "command" "subcom" "name" "version" "--zoption" )
  (bashop::command::__parse_arguments command[@] command_arguments[@] command_options[@] raw_arguments[@])
  assertion__status_code_is_success $?

  raw_arguments=( "command" "subcom" "name" "version" "--zoption" "--zoption" )
  fnc_string=$(bashop::command::__parse_arguments command[@] command_arguments[@] command_options[@] raw_arguments[@])
  assertion__string_contains "${fnc_string}" "Error: '--zoption' can't be multiple defined"

  raw_arguments=( "command" "subcom" "name" "version" "-i" )
  fnc_string=$(bashop::command::__parse_arguments command[@] command_arguments[@] command_options[@] raw_arguments[@])
  assertion__string_contains "${fnc_string}" "Error: Missing required argument for option '--ioption'"

  local tmp_command_arguments=( "<name>" "<version>" )
  raw_arguments=( "command" "subcom" "name" "version" "unkown" )
  fnc_string=$(bashop::command::__parse_arguments command[@] tmp_command_arguments[@] command_options[@] raw_arguments[@])
  assertion__string_contains "${fnc_string}" "Error: Unknown argument 'unkown'"

  raw_arguments=( "command" "subcom" "name" )
  fnc_string=$(bashop::command::__parse_arguments command[@] command_arguments[@] command_options[@] raw_arguments[@])
  assertion__string_contains "${fnc_string}" "Error: Missing required command argument '<version>'"
}