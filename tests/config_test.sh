#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/../src/bashop/modules/globals.sh
source ${DIR}/../src/bashop/modules/printer.sh
source ${DIR}/../src/bashop/modules/config.sh

function check_parse() {
  bashop::config::parse "${DIR}/fixtures/config"
  assertion__equal "string" "${BASHOP_CONFIG['var1']}"
  assertion__equal "1" "${BASHOP_CONFIG['VaR2']}"

  bashop::config::parse "${DIR}/fixtures/custom_config" "CUSTOM_CONFIG"
  assertion__equal "cust_string" "${CUSTOM_CONFIG['cust_var1']}"
  assertion__equal "1" "${CUSTOM_CONFIG['Cust_VaR2']}"
}

function check_write() {
  bashop::config::parse "${DIR}/fixtures/config"
  BASHOP_CONFIG["var1"]="changed"
  bashop::config::write "${DIR}/fixtures/tmp_config_new"

  local file_content="$(< ${DIR}/fixtures/config_new)"
  local tmp_file_content="$(< ${DIR}/fixtures/tmp_config_new)"
  rm "${DIR}/fixtures/tmp_config_new"

  assertion__equal "${file_content}" "${tmp_file_content}"

  bashop::config::parse "${DIR}/fixtures/custom_config" "CUSTOM_CONFIG"
  CUSTOM_CONFIG["cust_var1"]="cust_changed"
  bashop::config::write "${DIR}/fixtures/tmp_custom_config_new" "CUSTOM_CONFIG"

  local file_custom_content="$(< ${DIR}/fixtures/custom_config_new)"
  local tmp_file_custom_content="$(< ${DIR}/fixtures/tmp_custom_config_new)"
  rm "${DIR}/fixtures/tmp_custom_config_new"

  assertion__equal "${file_custom_content}" "${tmp_file_custom_content}"
}

function check_read_var_from_user_value() {
  mock__make_function_do_nothing "bashop::printer::info"

  # Default config tests
  mock__make_function_call "read" "value='value'"
  bashop::config::read_var_from_user "test_var"
  assertion__equal "value" "${BASHOP_CONFIG['test_var']}"

  mock__make_function_call "read" "value='value2'"
  bashop::config::read_var_from_user "test_var" "default_value"
  assertion__equal "value2" "${BASHOP_CONFIG['test_var']}"

  mock__make_function_do_nothing "read"

  bashop::config::read_var_from_user "test_var" "default_value"
  assertion__equal "value2" "${BASHOP_CONFIG['test_var']}"

  bashop::config::read_var_from_user "test_var2" "default_value"
  assertion__equal "default_value" "${BASHOP_CONFIG['test_var2']}"

  # Custom config tests
  mock__make_function_call "read" "value='custom_value'"

  bashop::config::read_var_from_user "custom_var" "custom_default_value" "" "CUSTOM_CONFIG"
  assertion__equal "custom_value" "${CUSTOM_CONFIG['custom_var']}"

  mock__make_function_do_nothing "read"

  bashop::config::read_var_from_user "custom_var" "custom_default_value" "" "CUSTOM_CONFIG"
  assertion__equal "custom_value" "${CUSTOM_CONFIG['custom_var']}"

  bashop::config::read_var_from_user "custom_var2" "custom_default_value" "" "CUSTOM_CONFIG"
  assertion__equal "custom_default_value" "${CUSTOM_CONFIG['custom_var2']}"
}

function check_read_var_from_user_output() {
  mock__make_function_do_nothing "read"

  fnc_text=$(bashop::config::read_var_from_user "test_var2" "default_value")
  test_string=$'\033[00;34mSet test_var2 [default_value]: \033[0m'
  assertion__equal "${test_string}" "${fnc_text}"

  fnc_text=$(bashop::config::read_var_from_user "test_var2" "default_value" "New text")
  test_string=$'\033[00;34mNew text [default_value]: \033[0m'
  assertion__equal "${test_string}" "${fnc_text}"
}