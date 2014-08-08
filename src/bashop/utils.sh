#!/usr/bin/env bash

##############################
# Checks if a variable is set
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   Bool
##############################
bashop::utils::isset() {
  if [[ ${1+isset} == 'isset' ]]; then
    return 0
  fi

  return 1
}

###############################################
# Checks if a array contains the given element
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   Bool
###############################################
bashop::utils::contains_element() {
  local e

  for e in "${@:2}"; do
    [[ "${e}" == "${1}" ]] && return 0
  done

  return 1
}

#####################################################
# Checks if the given key exists for the given array
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   Bool
#####################################################
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

bashop::utils::string_repeat() {
  if [[ ${2} -gt 0 ]]; then
    printf "${1}%.0s" $(eval "echo {1.."$(($2))"}")
  fi
}

bashop::utils::min_string_lenght() {
  local raw_args=("${!1}")
  echo $(bashop::utils::string_length raw_args[@] "min")
}

bashop::utils::max_string_lenght() {
  local raw_args=("${!1}")
  echo $(bashop::utils::string_length raw_args[@] "max")
}

bashop::utils::string_length() {
  local strings=("${!1}")
  local min_length=false
  local max_length=0
  local string

  for string in "${strings[@]}"; do
    if [[ ${min_length} == false ]] || [[ ${#string} -lt ${min_length} ]]; then
      min_length=${#string}
    fi

    if [[ ${#string} -gt ${max_length} ]]; then
      max_length=${#string}
    fi
  done

  if [[ ${2} == 'min' ]]; then
    echo ${min_length}
  elif [[ ${2} == 'max' ]]; then
    echo ${max_length}
  elif [[ ${2} == 'diff' ]]; then
    echo $((max_length - min_length))
  fi
}