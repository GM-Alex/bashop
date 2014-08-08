#!/usr/bin/env bash

bashop::app::show_help() {
  # Print app usage
  local app_name="${1}"
  bashop::logger::echo "Usage:"
  bashop::logger::echo "  ${app_name} <command> <arguments> [options]" "\n\n"
  bashop::logger::echo "Commands:"

  # Grep commands and show help page
  local commands=( "${BASHOP_APP_COMMAND_ROOT}/*" )
  local commands_to_show=()
  local command

  for command in ${commands[@]}; do
    source ${command}
    local command_name=$([[ ${command} =~ ([^\/]+)$ ]] && echo "${BASH_REMATCH[1]}")
    local command_description=''

    while read line; do
      if [[ ${line} =~ ^#\?d([ ]*)(.*)$ ]]; then
        command_description+="${BASH_REMATCH[2]}"
      fi
    done < "${command}"

    commands_to_show+=( "${command_name//_/ }  ${command_description}" )
  done

  bashop::logger::help_formater commands_to_show[@]

  #TODO add global options
}

bashop::app::start() {
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
      bashop::app::show_help ${app_name}
      ;;
    * )
      # Check if we have a valid command
      local possible_command=()
      local command=()
      local command_path=''
      local tmp_path="${BASHOP_APP_COMMAND_ROOT}/"
      local param

      for param in ${@}; do
        if !(bashop::utils::is_option ${param}); then
          tmp_path+=${param}
          possible_command+=( ${param} )

          if [[ -f "${tmp_path}" ]]; then
            command_path=${tmp_path}
            tmp_path+='_'
            command+=( ${param} )
          fi
        fi
      done

      if ! [[ -n ${command_path} ]]; then
        bashop::logger::error "The command '${possible_command[@]}' does not exists"
        exit 1
      fi

      # Grep options and arguments form the command file
      local command_arguments=()
      local command_options=()
      local line

      while read line; do
        if [[ ${line} =~ ^#\?c([ ]*)(.*)$ ]]; then
          command_arguments=( "${BASH_REMATCH[2]}" )
        elif [[ ${line} =~ ^#\?o([ ]*)(.*)$ ]]; then
          command_options+=( "${BASH_REMATCH[2]}" )
        fi
      done < "${command_path}"

      source "${command_path}"
      local raw_arguments=("${@}")

      # Check if arguments given
      local no_command=${#command[@]}
      local no_args=${#raw_arguments[@]}
      local diff=$((no_args - no_command))

      # If no arguments given and the command needs arguments show the help page
      if ( [[ ${#command_arguments[@]} -gt 0 ]] || [[ ${#command_options[@]} -gt 0 ]] ) && [[ ${diff} -lt 1 ]] ||
         (bashop::utils::contains_element '-h' ${raw_arguments[@]}) ||
         (bashop::utils::contains_element '--help' ${raw_arguments[@]})
      then
        local command_with_app_name=( "${app_name}" "${command[@]}" )
        bashop::command::show_help command_with_app_name[@] command_arguments[@] command_options[@]
      else
        bashop::command::parse_arguments command[@] command_arguments[@] command_options[@] raw_arguments[@]

        if (bashop::utils::function_exists "bashop::run_command"); then
          bashop::run_command
        else
          bashop::logger::framework_error "Every command must define the function bashop::run_command"
        fi
      fi
      ;;
  esac

  # Run app destroy function
  if (bashop::utils::function_exists "bashop::destroy"); then
    bashop::destroy
  fi
}

bashop::app::__check_dependencies