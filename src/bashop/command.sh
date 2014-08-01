#!/usr/bin/env bash

bashop::command::__check_dependencies() {
  if ! [[ -n ${BASHOP_COMMAND_ARGUMENTS+1} ]]; then
    bashop::logger::framework_error "The global variable 'BASHOP_COMMAND_ARGUMENTS' must be defined"
    exit 1
  fi

  local com_options=( ${!BASHOP_COMMAND_OPTIONS[@]} )

  if [[ ${#com_options[@]} -le 0 ]]; then
    bashop::logger::framework_error "The global variable 'BASHOP_COMMAND_OPTIONS' must be defined"
    exit 1
  fi
}

bashop::command::show_help() {
  bashop::command::__check_dependencies
}

bashop::command::parse_arguments() {
  bashop::command::__check_dependencies

  declare -g -A args=()

  # Get function agruments
  local raw_arguments=("${@}")

  # Get definied options
  local opt_required=()
  local opt_map opt_type_map opt_default_arg
  declare -A opt_map=()
  declare -A opt_type_map=()
  declare -A opt_default_arg=()

  for opt in "${!BASHOP_COMMAND_OPTIONS[@]}"; do
    local cur_opt=${opt}

    # Check if option is valid
    if ! [[ ${cur_opt} =~ ^([a-z]{1}\|){0,1}([a-zA-Z0-9\-]+)([?:+]{1})([=]{0,1})([a-zA-Z0-9\-]*)$ ]]; then
      bashop::logger::framework_error "Wrong pattern for option '${cur_opt}'"
      exit 1
    fi

    local short_opt_name=${BASH_REMATCH[1]//\|/}
    local full_opt_name="--${BASH_REMATCH[2]}"
    local opt_type=${BASH_REMATCH[3]}
    local has_arguments=${BASH_REMATCH[4]}
    local default_arg=${BASH_REMATCH[5]}

    # Get option names
    if [[ -n "${short_opt_name}" ]]; then
      opt_map["-${short_opt_name}"]=${full_opt_name}
    fi

    opt_map[${full_opt_name}]=${full_opt_name}

    # Get option type
    if [[ ${opt_type} == ":" ]]; then
      opt_required+=(${full_opt_name})
    fi

    opt_type_map[${full_opt_name}]=${opt_type}

    # Set default arg
    if [[ -n "${has_arguments}" ]]; then
      if [[ -n "${default_arg}" ]]; then
        opt_default_arg[${full_opt_name}]=${default_arg}
      else
        opt_default_arg[${full_opt_name}]=false
      fi
    fi
  done


  # Iterate over the raw argumgents
  local no_commands=${#_BASHOP_COMMAND[@]}
  local no_command_arguments=${#BASHOP_COMMAND_ARGUMENTS[@]}
  local start_options=$((no_commands + no_command_arguments))
  local no_raw_arguments=${#raw_arguments[@]}
  local arg=''
  local current_arg=''
  local counter=0
  local req_param_name=''

  while [[ ${counter} -lt ${no_raw_arguments} ]]; do
    arg=${raw_arguments[${counter}]}

    if [[ ${counter} -lt ${no_commands} ]] && !(bashop::utils::is_option ${arg}); then
      if [[ ${arg} != ${_BASHOP_COMMAND[${counter}]} ]]; then
        bashop::logger::framework_error "Unknown command '${arg}' called"
        exit 1
      fi
    elif [[ ${counter} -lt ${start_options} ]] && [[ ${counter} -ge ${no_commands} ]] && !(bashop::utils::is_option ${arg}); then
      req_param_name=${BASHOP_COMMAND_ARGUMENTS[$((counter - no_commands))]}
      args[${req_param_name}]=${arg}
    elif [[ ${counter} -ge ${start_options} ]] && (bashop::utils::is_option ${arg}); then
      if (bashop::utils::key_exists ${arg} opt_map); then
        arg=${opt_map[${arg}]}
      else
        bashop::logger::error "Invalid option '${arg}'"
        exit 1
      fi

      current_arg=${arg}
      local is_multiple_opt=false

      if [[ ${opt_type_map[${current_arg}]} == '+' ]]; then
        is_multiple_opt=true
      fi

      if ${is_multiple_opt} && !(bashop::utils::key_exists "${current_arg},#" args); then
        args["${current_arg},#"]=0
      elif !(${is_multiple_opt}) && !(bashop::utils::key_exists ${current_arg} args); then
        args[${current_arg}]=''
      elif (bashop::utils::key_exists ${current_arg} args) && [[ ${is_multiple_opt} ]]; then
        bashop::logger::error "'${current_arg}' can't be multiple definied"
        exit 1
      fi

      if (bashop::utils::key_exists "${current_arg}" opt_default_arg); then
        local opt_argument=false
        local next=$((counter + 1))

        if [[ ${next} -lt ${no_raw_arguments} ]]; then
          arg=${raw_arguments[${next}]}

          if [[ -n "${arg}" ]] && !(bashop::utils::is_option ${arg}); then
            opt_argument=${arg}
            counter=${next}
          fi
        fi

        if [[ ${opt_argument} == false ]] && [[ ${opt_default_arg["${current_arg}"]} != false ]]; then
          opt_argument=${opt_default_arg["${current_arg}"]}
        fi

        if [[ ${opt_argument} != false ]]; then
          if ${is_multiple_opt}; then
            local no_opt_args=${args["${current_arg},#"]}
            args["${current_arg},${no_opt_args}"]="${opt_argument}"
            args["${current_arg},#"]=$((no_opt_args+1))
          else
            args[${current_arg}]="${opt_argument}"
          fi
        else
          bashop::logger::error "Missing required argument for option '${current_arg}'"
          exit 1
        fi
      fi
    else
      if [[ ${counter} -lt ${no_commands} ]]; then
        bashop::logger::error "Invalide command '${arg}'"
      elif [[ ${counter} -lt ${start_options} ]]; then
        req_param_name=${BASHOP_COMMAND_ARGUMENTS[$((counter - no_commands))]}
        bashop::logger::error "Missing required parameter '${req_param_name}'"
      elif [[ ${counter} -ge ${start_options} ]]; then
        bashop::logger::error "Unknown option '${arg}'"
      fi

      exit 1
    fi

    counter=$((counter + 1))
  done

  # Check for missing required vars
  for req_opt in "${opt_required[@]}"; do
    if !(bashop::utils::key_exists ${req_opt} args); then
      bashop::logger::error "Option ${req_opt} is required"
      exit 1
    fi
  done
}