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
  local eval_exec="if [[ -z \"\${${1}[@]+1}\" ]]; then echo 'true'; fi"

  if [[ "$(eval "${eval_exec}")" == 'true' ]]; then
    eval_exec="declare -A -g ${1}=()"
    eval "${eval_exec}"
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

  if [[ -n ${2+1} ]]; then
    bashop::config::declare_custom ${2}
  fi

  if [[ -n ${file+1} ]] && [[ -f ${file} ]]; then
    while read -r line; do
      if [[ ${line} =~ ^[\ ]*(.*)=(.*)[\ ]*$ ]]; then
        if [[ -n ${2+1} ]]; then
          eval "${2}[\${BASH_REMATCH[1]}]=\${BASH_REMATCH[2]}"
        else
          BASHOP_CONFIG[${BASH_REMATCH[1]}]=${BASH_REMATCH[2]}
        fi
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

  if [[ -n ${file+1} ]] && [[ -n "${BASHOP_CONFIG[@]+1}" ]]; then
    local dir=${file%/*}

    if [[ ! -d ${dir} ]]; then
      mkdir -p ${dir}
    fi

    > ${file}
    local config_key

    if [[ -n ${1+1} ]] && [[ -n ${2+1} ]]; then
      bashop::config::declare_custom ${2}

      local eval_exec
      eval_exec="for config_key in \"\${!${2}[@]}\"; do "
      eval_exec+="echo \"\${config_key}=\${${2}[\${config_key}]}\" >> \${file}; "
      eval_exec+="done"

      eval "${eval_exec}"
    else
      for config_key in "${!BASHOP_CONFIG[@]}"; do
        echo "${config_key}=${BASHOP_CONFIG[${config_key}]}" >> ${file}
      done
    fi
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
  local eval_exec

  if [[ -n ${4+1} ]]; then
    bashop::config::declare_custom ${4}
    eval_exec="if [[ -n \"\${${4}[\${var_name}]+1}\" ]]; then echo 'true'; fi"
  fi

  if [[ -n ${4+1} ]] && [[ "$(eval "${eval_exec}")" == 'true' ]]; then
    eval_exec="default_value=\"\${${4}[\${var_name}]}\""
    eval "${eval_exec}"
  elif [[ -n ${BASHOP_CONFIG[${var_name}]+1} ]]; then
    default_value="${BASHOP_CONFIG[${var_name}]}"
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

  if [[ -n ${4+1} ]]; then
    eval "${4}[${var_name}]=${value}"
  else
    BASHOP_CONFIG[${var_name}]=${value}
  fi
}