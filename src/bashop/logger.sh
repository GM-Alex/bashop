#!/usr/bin/env bash

##########################################
# Default output command of the framework
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
##########################################
bashop::logger::echo() {
  printf '%s' "${1}"

  if ! [[ -n ${2+1} ]]; then
    printf "\n"
  elif [[ ${2} != false ]]; then
    printf "${2}"
  fi
}

##########################################
# Info output command
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
##########################################
bashop::logger::info() {
  printf "\033[00;34m"
  bashop::logger::echo "Info: ${1}" "${@:2}"
  printf "\033[0m"
}

##########################################
# User output command
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
##########################################
bashop::logger::user() {
  printf "\033[0;33m"
  bashop::logger::echo "${1}" "${@:2}"
  printf "\033[0m"
}

##########################################
# Success output command
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
##########################################
bashop::logger::success() {
  printf "\033[00;32m"
  bashop::logger::echo "${1}" "${@:2}"
  printf "\033[0m"
}

##########################################
# Error output command of the framework
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
##########################################
bashop::logger::error() {
  printf "\033[00;31m"
  bashop::logger::echo "Error: ${1}" "${@:2}"
  printf "\033[0m"
}

##########################################
# Verbose output command
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
##########################################
bashop::logger::verbose() {
  if [[ ${_BASHOP_VERBOSE} == true ]]; then
    printf "\033[00;34m"
    bashop::logger::echo "${1}" "${@:2}"
    printf "\033[0m"
  fi
}

##########################################
# Framework error output command
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
##########################################
bashop::logger::framework_error() {
  local msg=''
  msg+="It's not your fault... expect you are the developer of this application or worse "
  msg+="you are the user and changed something, than congratulations you broke it ;). "
  msg+="If you are a user and you didn't done something then please send the developer "
  msg+="of this application the following message as error report:\n\nFRAMEWORK ERROR: ${1}\n"

  printf "\033[00;31m"
  printf "${msg}"
  printf "\033[0m"
}

##########################################
# Formats the output for options
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
##########################################
bashop::logger::help_formater() {
  local help_texts=("${!1}")
  local help_text
  local help_regex="(.*)  (.*)"
  local help_text_first_parts=()

  for help_text in "${help_texts[@]}"; do
    if [[ ${help_text} =~ ${help_regex} ]]; then
      help_text_first_parts+=( "${BASH_REMATCH[1]}" )
    else
      bashop::logger::framework_error "Wrong syntax for '${help_text}'. Must be 'WHAT  DESCRIPTION' (two spaces)"
      exit 1
    fi
  done

  local max_length=$(bashop::utils::max_string_lenght help_text_first_parts[@])

  for help_text in "${help_texts[@]}"; do
    if [[ ${help_text} =~ ${help_regex} ]]; then
      local length=${#BASH_REMATCH[1]}
      local no_spaces=$((max_length - length))
      spaces=$(bashop::utils::string_repeat ' ' ${no_spaces})

      bashop::logger::echo "  ${BASH_REMATCH[1]}${spaces}  " false
      bashop::logger::echo "${BASH_REMATCH[2]}"
    fi
  done
}