#!/usr/bin/env bash

##############################
# Checks if a variable is set
# Globals:
#   None
# Arguments:
#   mixed variable
# Returns:
#   bool
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
#   array  haystack
# Returns:
#   bool
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
#   array  haystack
# Returns:
#   bool
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
#   bool
#######################################################
bashop::utils::is_option() {
  if [[ ${1} =~ ^-{1,2}[^-].* ]]; then
    return 0
  fi

  return 1
}

######################################
# Checks if the given function exists
# Globals:
#   None
# Arguments:
#   string function_name
# Returns:
#   bool
######################################
bashop::utils::function_exists() {
  echo ${1}
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
    eval="echo {1.."$(($2))"}"
    printf "${1}%.0s" $(eval ${eval})
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
bashop::utils::min_string_length() {
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
bashop::utils::max_string_length() {
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
  local string=()

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

##########################################################
# Checks if the min version is lower than the cur version
# Globals:
#   None
# Arguments:
#   string min_version
#   string cur_version
# Returns:
#   bool
##########################################################
bashop::utils::check_version() {
  local min_version=${1}
  local mv=()
  local cur_version=${2}
  local cv=()
  local version_regex="^([0-9]+)\.([0-9]+)\.([0-9]+).*"

  if [[ ${min_version} =~ ${version_regex} ]]; then
    mv+=( ${BASH_REMATCH[1]} )
    mv+=( ${BASH_REMATCH[2]} )
    mv+=( ${BASH_REMATCH[3]} )
  else
    bashop::printer::error "Wrong version format for '${min_version}'."
    exit 1
  fi

  if [[ ${cur_version} =~ ${version_regex} ]]; then
    cv+=( ${BASH_REMATCH[1]} )
    cv+=( ${BASH_REMATCH[2]} )
    cv+=( ${BASH_REMATCH[3]} )
  else
    bashop::printer::error "Wrong version format for '${cur_version}'."
    exit 1
  fi

  if ( [[ ${mv[0]} -lt ${cv[0]} ]] ) ||
     ( [[ ${mv[0]} -le ${cv[0]} ]] && [[ ${mv[1]} -lt ${cv[1]} ]] ) ||
     ( [[ ${mv[0]} -le ${cv[0]} ]] && [[ ${mv[1]} -le ${cv[1]} ]] && [[ ${mv[2]} -lt ${cv[2]} ]] )
  then
    return 0
  fi

  return 1
}