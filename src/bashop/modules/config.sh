#!/usr/bin/env bash
#############################################
# Helper function to declare a custom config
# Globals:
#   None
# Arguments:
#   string custom_config
# Returns:
#   None
#############################################
bashop::config::declare_custom() {
  declare -n config_array=${1}

  if [[ -z ${config_array[@]+1} ]]; then
    declare -A -g "${1}"
  fi
}

###############################################################
# Parses a config file and loads it to the global config array
# Globals:
#   BASHOP_CONFIG_FILE
#   _BASHOP_CONFIG
# Arguments:
#   string file (optional)
#   string custom_config (optional)
# Returns:
#   None
###############################################################
bashop::config::parse() {
  local file

  if [[ -n ${1+1} ]]; then
    file=${1}
  elif [[ -n ${BASHOP_CONFIG_FILE+1} ]]; then
    file=${BASHOP_CONFIG_FILE}
  fi

  local config_array_name='BASHOP_CONFIG'

  if [[ -n ${2+1} ]]; then
    bashop::config::declare_custom ${2}
    config_array_name=${2}
  fi

  declare -n config_array=${config_array_name}

  if [[ -n ${file+1} ]] && [[ -f ${file} ]]; then
    while read -r line; do
      if [[ ${line} =~ ^[\ ]*(.*)=(.*)[\ ]*$ ]]; then
        config_array[${BASH_REMATCH[1]}]=${BASH_REMATCH[2]}
      fi
    done < ${file}
  fi
}

###################################
# Writes the config back to a file
# Globals:
#   BASHOP_CONFIG_FILE
#   _BASHOP_CONFIG
# Arguments:
#   string file (optional)
#   string custom_config (optional)
# Returns:
#   None
###################################
bashop::config::write() {
  local file

  if [[ -n ${1+1} ]]; then
    file=${1}
  elif [[ -n ${BASHOP_CONFIG_FILE+1} ]]; then
    file=${BASHOP_CONFIG_FILE}
  fi

  if [[ -n ${file+1} ]]; then
    local dir=${file%/*}

    if [[ ! -d ${dir} ]]; then
      mkdir -p ${dir}
    fi

    > ${file}

    local config_array_name='BASHOP_CONFIG'

    if [[ -n ${1+1} ]] && [[ -n ${2+1} ]]; then
      bashop::config::declare_custom ${2}
      config_array_name=${2}
    fi

    declare -n config_array=${config_array_name}
    local config_key

    for config_key in "${!config_array[@]}"; do
      echo "${config_key}=${config_array[${config_key}]}" >> ${file}
    done
  fi
}

######################################################################
# Reads a config value from the user an stores it to the config array
# Globals:
#   BASHOP_CONFIG_FILE
#   _BASHOP_CONFIG
# Arguments:
#   string var_name
#   string default_value (optional)
#   string prompt (optional)
#   string custom_config (optional)
# Returns:
#   None
######################################################################
bashop::config::read_var_from_user() {
  local var_name=${1}
  local default_value
  local prompt="Set ${var_name}"

  local config_array_name='BASHOP_CONFIG'

  if [[ -n ${4+1} ]]; then
    bashop::config::declare_custom ${4}
    config_array_name=${4}
  fi

  declare -n config_array=${config_array_name}

  if [[ -n ${config_array[${var_name}]+1} ]]; then
    default_value="${config_array[${var_name}]}"
  elif [[ -n ${2+1} ]]; then
    default_value=${2}
  fi

  if [[ -n ${3+1} ]] && [[ ${3} != "" ]]; then
    prompt=${3}
  fi

  if [[ -n ${default_value+1} ]]; then
    prompt+=" [${default_value}]"
  fi

  bashop::printer::info "${prompt}: " false
  local value
  read value

  if [[ ${value} == "" ]]; then
    value=${default_value}
  fi

   config_array[${var_name}]=${value}
}