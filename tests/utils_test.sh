#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/../src/bashop/modules/printer.sh
source ${DIR}/../src/bashop/modules/utils.sh

function check_isset() {
  local set_var="set"

  (bashop::utils::isset ${set_var})
  assertion__status_code_is_success $?

  (bashop::utils::isset ${none_set_var})
  assertion__status_code_is_failure $?
}

function check_contains_element() {
  local array=( "element1" "element2" )

  (bashop::utils::contains_element 'element1' ${array[@]})
  assertion__status_code_is_success $?

  (bashop::utils::contains_element 'element2' ${array[@]})
  assertion__status_code_is_success $?

  (bashop::utils::contains_element 'element3' ${array[@]})
  assertion__status_code_is_failure $?
}

function check_key_exists() {
  declare -A array=()
  array["key1"]="value1"

  (bashop::utils::key_exists 'key1' array)
  assertion__status_code_is_success $?

  (bashop::utils::key_exists 'key2' array)
  assertion__status_code_is_failure $?
}

function check_is_option() {
  local short_option='-o'
  local long_option='--option'
  local wrong_option='---wrong_option'
  local none_option='none_option'

  (bashop::utils::is_option ${short_option})
  assertion__status_code_is_success $?

  (bashop::utils::is_option ${long_option})
  assertion__status_code_is_success $?

  (bashop::utils::is_option ${wrong_option})
  assertion__status_code_is_failure $?

  (bashop::utils::is_option ${none_option})
  assertion__status_code_is_failure $?
}

function check_function_exists() {
  (bashop::utils::function_exists check_function_exists)
  assertion__status_code_is_success $?

  (bashop::utils::function_exists no_function)
  assertion__status_code_is_failure $?
}

function check_string_repeat() {
  assertion__equal "####" $(bashop::utils::string_repeat '#' 4)
}

function check_min_string_length() {
  local array=( "##" "#####" "#" "###" )
  assertion__equal 1 $(bashop::utils::min_string_length array[@])
}

function check_max_string_length() {
  local array=( "##" "#####" "#" "###" )
  assertion__equal 5 $(bashop::utils::max_string_length array[@])
}

function check_string_length() {
  local array=( "##" "#####" "#" "###" )
  assertion__equal 1 $(bashop::utils::string_length array[@] 'min')
  assertion__equal 5 $(bashop::utils::string_length array[@] 'max')
  assertion__equal 4 $(bashop::utils::string_length array[@] 'diff')
}

function check_check_version() {
  mock__make_function_do_nothing "bashop::printer::error"

  (bashop::utils::check_version '1.2.3' '2.0.0')
  assertion__status_code_is_success $?

  (bashop::utils::check_version '2.0.0' '1.2.3' )
  assertion__status_code_is_failure $?

  (bashop::utils::check_version '1.2' '2.0.0' )
  assertion__status_code_is_failure $?

  (bashop::utils::check_version '1.2.3' '2.0' )
  assertion__status_code_is_failure $?
}

function check_run_commands() {
  local commands=()
  commands+=( "echo \"hello\"" )
  commands+=( "echo \"world\"" )
  commands+=( "echo \"!\"" )

  _BASHOP_VERBOSE=true
  local fnc_string=$(bashop::utils::run_commands commands[@])
  local test_string=''
  test_string+=$'[1/3] ###        (33%) | Running: \'echo "hello"\'\n'
  test_string+=$'hello\n'
  test_string+=$'[2/3] ######     (66%) | Running: \'echo "world"\'\n'
  test_string+=$'world\n'
  test_string+=$'[3/3] ########## (100%) | Running: \'echo "!"\'\n'
  test_string+=$'!'
  assertion__equal "${test_string}" "${fnc_string}"

  _BASHOP_VERBOSE=false
  fnc_string=$(bashop::utils::run_commands commands[@])
  test_string=''
  test_string+=$'\r\033[K[1/3] ###        (33%) | Running: \'echo "hello"\''
  test_string+=$'\r\033[K[2/3] ######     (66%) | Running: \'echo "world"\''
  test_string+=$'\r\033[K[3/3] ########## (100%) | Running: \'echo "!"\''
  assertion__equal "${test_string}" "${fnc_string}"

  commands=( "command_does_not_exist" )
  commands+=( "echo \"hello\"" )
  assertion__failing $(bashop::utils::run_commands commands[@])
}