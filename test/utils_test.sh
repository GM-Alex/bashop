#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/../src/bashop/utils.sh
source ${DIR}/../src/bashop/logger.sh

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

function check_associative_array_exists() {
  declare -A associative_array=()
  associative_array["key1"]="value1"

  (bashop::utils::associative_array_exists associative_array)
  assertion__status_code_is_success $?

  (bashop::utils::associative_array_exists not_existing_associative_array)
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
  (bashop::utils::check_version '1.2.3' '2.0.0')
  assertion__status_code_is_success $?

  (bashop::utils::check_version '2.0.0' '1.2.3' )
  assertion__status_code_is_failure $?

  (bashop::utils::check_version '1.2' '2.0.0' )
  assertion__status_code_is_failure $?

  (bashop::utils::check_version '1.2.3' '2.0' )
  assertion__status_code_is_failure $?
}