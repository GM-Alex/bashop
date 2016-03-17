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
  local check="[ \${${2}[${1}]+key_exists} ]"
  eval ${check}
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

#####################################
# Checks if the command is available
# Globals:
#   None
# Arguments:
#   string command
# Returns:
#   bool
#####################################
bashop::utils::command_exists() {
  local command=${1}

  if command -v ${command} >/dev/null 2>&1; then
    return 0
  else
    return 1
  fi
}

##############################
# Prints the command progress
# Globals:
#   _BASHOP_VERBOSE
# Arguments:
#   integer counter
#   integer number_of_commands
#   string  command_text
# Returns:
#   None
##############################
bashop::utils::print_command_status() {
  local counter=${1}
  local step_counter=${counter}
  local number_of_commands=${2}

  if [[ ${counter} -lt ${number_of_commands} ]]; then
    step_counter=$(( counter + 1 ))
  fi

  local command_text=${3}
  local step_percent=$(( (counter * 100) / number_of_commands ))
  local status="[${step_counter}/${number_of_commands}] "
  status+=$(bashop::utils::string_repeat "#" $(( step_percent/10 )))
  status+=$(bashop::utils::string_repeat " " $(( 10 - (step_percent/10) )))
  status+=" (${step_percent}%)"
  status+=${command_text}

  if [[ ${_BASHOP_VERBOSE} == false ]]; then
    echo -ne "\r\033[K${status}"
  else
    echo "${status}"
  fi
}

################################################
# Runs multiple commands and shows the progress
# Globals:
#   _BASHOP_VERBOSE
# Arguments:
#   array  commands
#   string command_prefix
# Returns:
#   None
################################################
bashop::utils::run_commands() {
  local commands=("${!1}")
  local command_prefix=""

  if [[ -n ${2+1} ]]; then
    command_prefix=${2}
  fi

  if [[ ${command_prefix} == "sudo" ]]; then
    sudo sleep 0.1
  fi

  local number_of_commands=${#commands[@]}
  local counter=0
  local full_command
  local status
  local step_percent
  local command
  local return_value
  local return_code

  for command in "${commands[@]}"; do
    if [[ ${command_prefix} != "" ]]; then
      full_command="${command_prefix} ${command}"
    else
      full_command="${command}"
    fi

    if [[ ${_BASHOP_VERBOSE} == false ]]; then
      full_command+="&> /dev/null"
    fi

    bashop::utils::print_command_status ${counter} ${number_of_commands} " | Running: '${command}'"

    eval "${full_command}"
    return_code=$?

    if [[ ${return_code} != 0 ]]; then
      if [[ ${_BASHOP_VERBOSE} == false ]]; then
        echo -ne "\n"
      fi

      bashop::printer::error "Error ${return_code} on executing '${command}'"
      exit ${return_code}
    fi

    counter=$((counter + 1))
  done

  bashop::utils::print_command_status ${counter} ${number_of_commands} " | Completed"

  if [[ ${_BASHOP_VERBOSE} == false ]]; then
    echo -ne "\n"
  fi
}