#!/usr/bin/env bash

bashop::utils::isset() {
  if [[ ${1+isset} == 'isset' ]]; then
    return 0
  fi

  return 1
}

bashop::contains_element() {
  local e
  for e in "${@:2}"; do [[ "${e}" == "${1}" ]] && return 0; done
  return 1
}

bashop::utils::key_exists() {
  eval '[ ${'${2}'[${1}]+key_exists} ]'
}

bashop::utils::is_option() {
  if [[ ${1} =~ ^-{1,2}.* ]]; then
    return 0
  fi

  return 1
}

bashop::utils::associative_array_exists() {
    declare -g -A ${1} > /dev/null
    return $?
}

bashop::utils::function_exists() {
    declare -f -F ${1} > /dev/null
    return $?
}