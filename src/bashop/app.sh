#!/usr/bin/env bash

bashop::app::__check_dependencies() {
  if ! [[ -n ${_BASHOP_APP_NAME+1} ]]; then
    bashop::logger::framework_error "Error the global variable '_BASHOP_APP_NAME' must be defined"
    exit 1
  fi
}

bashop::app::show_help() {
  bashop::logger::info 'Usage: '
  bashop::logger::info "${_BASHOP_APP_NAME} <command> <arguments> [options]"
  bashop::logger::info '  help:  show this help'

  local commands=( "${_BASHOP_APP_COMMAND_ROOT}/*" )

  for command in ${commands}; do
    source ${command}
    local single_command=$([[ ${command} =~ ([^\/]+)$ ]] && echo "${BASH_REMATCH[1]}")
    bashop::logger::info "  ${single_command}:  " false
    bashop::logger::info "${_BASHOP_COMMAND_DESCRIPTION}"
  done

  exit 0
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
      local tmp_path="${_BASHOP_APP_COMMAND_ROOT}/"

      for param in ${@}; do
        if !(bashop::utils::is_option ${param}); then
          command+=${param}
          tmp_path+=${param}

          if [[ -f "${tmp_path}" ]]; then
            command_path=${tmp_path}
            command+=' '
            tmp_path+='_'
            _BASHOP_COMMAND+=(${param})
          fi
        fi
      done

      if ! [[ -n ${command_path} ]]; then
        bashop::logger::error "The command '${command}' does not exists"
        exit 1
      fi

      source "${command_path}"
      bashop::command::parse_arguments ${@}

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