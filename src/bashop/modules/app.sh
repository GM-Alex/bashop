#!/usr/bin/env bash

##################################
# Shows the application help page
# Globals:
#   None
# Arguments:
#   string app_name
# Returns:
#   None
##################################
bashop::app::__show_help() {
  # Print app usage
  local app_name="${1}"
  bashop::printer::echo "Usage:"
  bashop::printer::echo "  ${app_name} <command> [options] <arguments>" "\n\n"
  bashop::printer::echo "Commands:"

  local commands=( ${0} )

  if [[ -d ${BASHOP_APP_COMMAND_ROOT} ]]; then
    commands=( ${BASHOP_APP_COMMAND_ROOT}/* )
  fi

  # Grep commands and show help page

  local commands_to_show=()
  local command

  for command in "${commands[@]}"; do
    local command_name=$([[ ${command} =~ ([^\/]+)$ ]] && echo "${BASH_REMATCH[1]}")
    local command_description=''

    while read line; do
      if [[ ${line} =~ ^#\?com([ ]*)(.*)$ ]]; then
        command_name=${BASH_REMATCH[2]}
      elif [[ ${line} =~ ^#\?d([ ]*)(.*)$ ]]; then
        command_description+="${BASH_REMATCH[2]}"
      elif [[ "${command_description}" != "" ]]; then
        commands_to_show+=( "${command_name//_/ }  ${command_description}" )
        command_description=''
      fi
    done < "${command}"
  done

  bashop::printer::help_formatter commands_to_show[@]

  bashop::printer::echo "" "\n"
  bashop::printer::echo "Options:"
  bashop::printer::help_formatter _BASHOP_BUILD_IN_OPTIONS[@]
}

#########################
# Starts the application
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
#########################
bashop::app::__start() {
  # Parses config if set
  if [[ -n ${BASHOP_CONFIG_FILE+1} ]]; then
    bashop::config::parse
  fi

  # Run app init function
  if (bashop::utils::function_exists "bashop::init"); then
    bashop::init
  fi

  # Get app name
  local app_name=$([[ ${0} =~ ([^\/]+)$ ]] && echo "${BASH_REMATCH[1]}")

  # Execute command
  local first_command=''

  if [[ -n ${1+1} ]]; then
    first_command="${1}"
  fi

  case "${first_command}" in
    "" | "-h" | "--help" )
      bashop::app::__show_help ${app_name}
      ;;
    * )
      # Check if we have a valid command
      local possible_command=()
      local command=()
      local command_path="${0}"
      local tmp_path="${BASHOP_APP_COMMAND_ROOT}/"
      local param

      for param in ${@}; do
        if !(bashop::utils::is_option ${param}); then
          possible_command+=( ${param} )
        fi
      done

      if [[ ${#possible_command[@]} -lt 1 ]]; then
        bashop::printer::error "No command given"
        exit 0
      fi

      local line

      while read line; do
        if [[ ${line} =~ ^#\?com([ ]*)(.*)$ ]]; then
          _BASHOP_KNOWN_COMMANDS+=( ${BASH_REMATCH[2]} )
        fi
      done < ${0}

      local command_param
      local command_name=''

      for command_param in "${possible_command[@]}"; do
        if (bashop::utils::contains_element "${command_name}${command_param}" "${_BASHOP_KNOWN_COMMANDS[@]}"); then
          command+=( ${command_param} )
          command_name+="${command_param}_"
        fi
      done

      if [[ ${#command_name} -gt 0 ]]; then
        command_name=${command_name::-1}
        echo ${command_name}
      else
        bashop::printer::error "Command '${possible_command[0]}' not found"
        exit 0
      fi

      if [[ -d ${BASHOP_APP_COMMAND_ROOT} ]]; then
        command_path="${BASHOP_APP_COMMAND_ROOT}/${command_name}"
      fi

      # Grep options and arguments form the command file
      local command_arguments=()
      local command_options=()
      local inline_command_processed=false

      while read line; do
        if [[ ${line} =~ ^#\?com([ ]*)(${command_name})([ ]*)$ ]]; then
          command_arguments=()
          command_options=()
          inline_command_processed=true
        elif [[ ${line} =~ ^#\?c([ ]*)(.*)$ ]]; then
          command_arguments=( ${BASH_REMATCH[2]} )
        elif [[ ${line} =~ ^#\?o([ ]*)(.*)$ ]]; then
          command_options+=( "${BASH_REMATCH[2]}" )
        fi
      done < "${command_path}"

      local raw_arguments=("${@}")

      # Check if arguments given
      local no_command=${#command[@]}
      local no_args=${#raw_arguments[@]}
      local diff=$((no_args - no_command))

      # Set verbose mode
      if (bashop::utils::contains_element '-v' "${raw_arguments[@]}") ||
         (bashop::utils::contains_element '--verbose' "${raw_arguments[@]}")
      then
        _BASHOP_VERBOSE=true
        local raw_arg
        local raw_args_copy=( "${raw_arguments[@]}" )
        raw_arguments=()

        for raw_arg in "${raw_args_copy[@]}"; do
          if [[ ${raw_arg} != '-v' ]] && [[ ${raw_arg} != '--verbose' ]]; then
            raw_arguments+=( ${raw_arg} )
          fi
        done
      fi

      # If no arguments given and the command needs arguments show the help page
      if ( [[ ${#command_arguments[@]} -gt 0 ]] ) && [[ ${diff} -lt 1 ]] ||
         (bashop::utils::contains_element '-h' "${raw_arguments[@]}") ||
         (bashop::utils::contains_element '--help' "${raw_arguments[@]}")
      then
        local command_with_app_name=( "${app_name}" "${command[@]}" )
        bashop::command::__show_help command_with_app_name[@] command_arguments[@] command_options[@]
      else
        bashop::command::__parse_arguments command[@] command_arguments[@] command_options[@] raw_arguments[@]

        if (bashop::utils::function_exists "bashop::run_command::${command_name}"); then
          eval "bashop::run_command::${command_name}"
        else
          bashop::printer::__framework_error "Every command must define the function bashop::run_command::COMMAND_NAME"
        fi
      fi
      ;;
  esac

  # Run app destroy function
  if (bashop::utils::function_exists "bashop::destroy"); then
    bashop::destroy
  fi
}