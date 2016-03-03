#!/usr/bin/env bash
##############################################################
# Parses a config file and loads it to the global config array
# Globals:
#   BASHOP_CONFIG_FILE
#   _BASHOP_CONFIG
# Arguments:
#   string file (optional)
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

  if [[ -n ${file+1} ]] && [[ -f ${file} ]]; then
    while read -r line; do
      if [[ ${line} =~ ^[\ ]*(.*):[\ ]*(.*)[\ ]*$ ]]; then
        BASHOP_CONFIG[${BASH_REMATCH[1]}]=${BASH_REMATCH[2]}
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

  if [[ -n ${file+1} ]] && [[ -n "${BASHOP_CONFIG[@]+1}" ]]; then
    local dir=${file%/*}

    if [[ ! -d ${dir} ]]; then
      mkdir -p ${dir}
    fi

    > ${file}
    local config_key

    for config_key in "${!BASHOP_CONFIG[@]}"; do
      echo "${config_key}: ${BASHOP_CONFIG[${config_key}]}" >> ${file}
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
# Returns:
#   None
######################################################################
bashop::config::read_var_from_user() {
  local var_name=${1}
  local default_value
  local prompt="Set ${var_name}"

  if [[ -n ${BASHOP_CONFIG[${var_name}]+1} ]]; then
    default_value="${BASHOP_CONFIG[${var_name}]}"
  elif [[ -n ${2+1} ]]; then
    default_value=${2}
  fi

  if [[ -n ${3+1} ]]; then
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

  BASHOP_CONFIG[${var_name}]=${value}
}