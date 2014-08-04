#!/usr/bin/env bash

bashop::app::__check_dependencies() {
  if ! [[ -n ${BASHOP_APP_NAME+1} ]]; then
    bashop::logger::framework_error "The global variable 'BASHOP_APP_NAME' must be defined"
    exit 1
  fi
}

bashop::app::show_help() {
  bashop::logger::info "Usage:"
  bashop::logger::info "  ${BASHOP_APP_NAME} <command> <arguments> [options]\n"
  bashop::logger::info "Commands:"

  local commands=( "${BASHOP_APP_COMMAND_ROOT}/help" "${BASHOP_APP_COMMAND_ROOT}/*" )
  local max_length=$(bashop::utils::max_string_lenght ${commands[@]})
  BASHOP_COMMAND_DESCRIPTION='show this help'

  for command in ${commands[@]}; do
    if ! [[ ${command} =~ \/help$ ]]; then
      source ${command}
    fi

    local single_command=$([[ ${command} =~ ([^\/]+)$ ]] && echo "${BASH_REMATCH[1]}")
    local length=${#command}
    local no_spaces=$((max_length - length))
    spaces=$(bashop::utils::string_repeat ' ' ${no_spaces})

    bashop::logger::info "  ${single_command//_/ }${spaces}  " false
    bashop::logger::info "${BASHOP_COMMAND_DESCRIPTION}"
  done
}

bashop::app::start() {
  if (bashop::utils::function_exists "bashop::init"); then
    bashop::init
  fi

  # Execute command
  _BASHOP_COMMAND=()
  local first_command=''

  if [[ -n ${1+1} ]]; then
    first_command="${1}"
  fi

  case "${first_command}" in
    "" | "-h" | "--help" )
      bashop::app::show_help
      ;;
    * )
      local command=''
      local command_path=''
      local tmp_path="${BASHOP_APP_COMMAND_ROOT}/"

      for param in ${@}; do
        if !(bashop::utils::is_option ${param}); then
          command+=${param}
          tmp_path+=${param}

          if [[ -f "${tmp_path}" ]]; then
            command_path=${tmp_path}
            command+=' '
            tmp_path+='_'
            _BASHOP_COMMAND+=( ${param} )
          fi
        fi
      done

      readonly _BASHOP_COMMAND

      if ! [[ -n ${command_path} ]]; then
        bashop::logger::error "The command '${command}' does not exists"
        exit 1
      fi

      local command_arguments=()
      local command_options=()

      while read line; do
        if [[ ${line} =~ ^#\?c([ ]*)(.*)$ ]]; then
          command_arguments=( "${BASH_REMATCH[2]}" )
        elif [[ ${line} =~ ^#\?o([ ]*)(.*)$ ]]; then
          command_options+=( "${BASH_REMATCH[2]}" )
        fi
      done < "${command_path}"

      source "${command_path}"
      local raw_arguments=("${@}")
      bashop::command::parse_arguments command_arguments[@] command_options[@] raw_arguments[@]

      if (bashop::utils::function_exists "bashop::run_command"); then
        bashop::run_command
      else
        bashop::logger::framework_error "Every command must define the function bashop::run_command"
      fi
      ;;
  esac

  if (bashop::utils::function_exists "bashop::destroy"); then
    bashop::destroy
  fi
}

bashop::app::__check_dependencies