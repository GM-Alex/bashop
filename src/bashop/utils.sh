#!/usr/bin/env bash

##############################
# Checks if a variable is set
# Globals:
#   None
# Arguments:
#   mixed variable
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
#   string needle
#   array  hackstay
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
#   string needle
#   array  hackstay
# Returns:
#   Bool
#####################################################
bashop::utils::key_exists() {
  eval '[ ${'${2}'[${1}]+key_exists} ]'
}

#######################################################
# Checks if the given string matches the option format
# Globals:
#   None
# Arguments:
#   string option
# Returns:
#   Bool
#######################################################
bashop::utils::is_option() {
  if [[ ${1} =~ ^-{1,2}.* ]]; then
    return 0
  fi

  return 1
}

####################################################################
# Checks if the given var is an associative array which is declared
# Globals:
#   None
# Arguments:
#   string array_name
# Returns:
#   Bool
####################################################################
bashop::utils::associative_array_exists() {
  declare -g -A ${1} > /dev/null
  return $?
}

######################################
# Checks if the given function exists
# Globals:
#   None
# Arguments:
#   string function_name
# Returns:
#   Bool
######################################
bashop::utils::function_exists() {
  declare -f -F ${1} > /dev/null
  return $?
}

##################################
# Repeat the given string n times
# Globals:
#   None
# Arguments:
#   string string_to_repeat
#   int    repeat_times
# Returns:
#   string
##################################
bashop::utils::string_repeat() {
  if [[ ${2} -gt 0 ]]; then
    printf "${1}%.0s" $(eval "echo {1.."$(($2))"}")
  fi
}

#################################################################
# Finds the min length of a collection of strings given by array
# Globals:
#   None
# Arguments:
#   array search
# Returns:
#   int
#################################################################
bashop::utils::min_string_lenght() {
  local search=("${!1}")
  echo $(bashop::utils::string_length search[@] "min")
}

#################################################################
# Finds the max length of a collection of strings given by array
# Globals:
#   None
# Arguments:
#   array search
# Returns:
#   int
#################################################################
bashop::utils::max_string_lenght() {
  local search=("${!1}")
  echo $(bashop::utils::string_length search[@] "max")
}

#############################################################
# Finds the length of a collection of strings given by array
# Globals:
#   None
# Arguments:
#   array  search
#   string type   Possible values are be min, max or diff
# Returns:
#   int
#############################################################
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

  local type=${2}

  if [[ ${type} == 'min' ]]; then
    echo ${min_length}
  elif [[ ${type} == 'max' ]]; then
    echo ${max_length}
  elif [[ ${type} == 'diff' ]]; then
    echo $((max_length - min_length))
  fi
}