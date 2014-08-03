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
            _BASHOP_COMMAND+=(${param})
          fi
        fi
      done

      if ! [[ -n ${command_path} ]]; then
        bashop::logger::error "The command '${command}' does not exists"
        exit 1
      fi

      local com_arg='(([\<][a-zA-Z0-9]+[\>])([.]{3}){0,1})'
      local com_arg_requried_regex="^${com_arg}$"
      local com_arg_optional_regex="^\[${com_arg}\]$"

      #Check for right comment syntax and cut out leading spaces
      local option_regex='^#\?o([ ]*)'

      #Get short option
      option_regex+='('
      option_regex+='(-[a-zA-Z]{1})([.]{3}){0,1}'
      option_regex+='( ([\<][a-z]+[\>])| ([A-Z]+)){0,1}'
      option_regex+='){0,1}'

      #Option divider
      option_regex+='[,]{0,1} '

      #Get long option
      option_regex+='('
      option_regex+='(--[a-zA-Z0-9\-]+)([.]{3}){0,1}'
      option_regex+='(=([\<][a-z]+[\>])| ([A-Z]+)){0,1}'
      option_regex+='){0,1}'

      #Check for default value
      option_regex+='([^\[]*)(\[default: ([a-zA-Z0-9]+)\]){0,1}.*$'

      while read line; do
          if [[ ${line} =~ ^#\?c([ ]*)(.*)$ ]]; then
            local com_args=( "${BASH_REMATCH[2]}" )

            for com_arg in ${com_args[@]}; do
              if [[ ${com_arg} =~ ${com_arg_requried_regex} ]]; then
                echo "Requried: ${com_arg}"
              elif [[ ${com_arg} =~ ${com_arg_optional_regex} ]]; then
                echo "Optional: ${com_arg}"
              fi
            done

            exit
          elif [[ ${line} =~ ${option_regex} ]]; then
            echo "--- Option ---"

            echo "Short: ${BASH_REMATCH[3]}"
            echo "Short repeat: ${BASH_REMATCH[4]}"
            echo "Short Arg #1: ${BASH_REMATCH[6]}"
            echo "Short Arg #2: ${BASH_REMATCH[7]}"
            echo "Long: ${BASH_REMATCH[9]}"
            echo "Long repeat: ${BASH_REMATCH[10]}"
            echo "Long Arg #1: ${BASH_REMATCH[12]}"
            echo "Long Arg #2: ${BASH_REMATCH[13]}"
            echo "Default: ${BASH_REMATCH[16]}"
            echo ""
          fi
      done < "${command_path}"

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