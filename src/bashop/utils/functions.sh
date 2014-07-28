#!/usr/bin/env bash

bashop::contains_element () {
  local e
  for e in "${@:2}"; do [[ "${e}" == "${1}" ]] && return 0; done
  return 1
}

bashop::key_exists() {
  eval '[ ${'${2}'[${1}]+key_exists} ]'
}

bashop::is_option() {
  if [[ ${1} == --* ]] || [[ ${1} == -* ]]; then
    return 0
  fi

  return 1
}

bashop::function_exists() {
    declare -f -F ${1} > /dev/null
    return $?
}