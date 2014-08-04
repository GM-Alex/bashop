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

  #TODO make local and store later global as read only
  declare -g -A args=()

  #Get function agruments
  local command_arguments=("${!1}")
  local command_options=("${!2}")
  local raw_arguments=("${!3}")

  #Regex for options
  local short_option_regex='(-[a-zA-Z]{1})([.]{3}){0,1}'
  short_option_regex+='( ([\<][a-z]+[\>])| ([A-Z]+)){0,1}'
  local long_option_regex='(--[a-zA-Z0-9\-]+)([.]{3}){0,1}'
  long_option_regex+='(=([\<][a-z]+[\>])| ([A-Z]+)){0,1}'

  #---- Command arguments ----

  #Command regex
  local command_arg_regex='(([\<][a-zA-Z0-9]+[\>])([.]{3}){0,1})'
  local commmand_arg_requried_regex="^${command_arg_regex}$"
  local commmand_arg_optional_regex="^\[${command_arg_regex}\]$"

  #Get command arguments
  for command_argument in ${command_arguments[@]}; do
    if [[ ${command_argument} =~ ${commmand_arg_requried_regex} ]]; then
      echo "Requried: ${command_argument}"
    elif [[ ${command_argument} =~ ${commmand_arg_optional_regex} ]]; then
      echo "Optional: ${command_argument}"
    elif [[ ${command_argument} =~ ${short_option_regex} ]] || [[ ${command_argument} =~ ${long_option_regex} ]]; then
      command_options+=( ${command_argument} )
    fi
  done


  #---- Command options ----

  #Get definied options
  local opt_map opt_repeatable opt_default_arg
  declare -A opt_map=()
  declare -A opt_repeatable=()
  declare -A opt_default_arg=()

  #Short option regex
  local option_regex+="^(${short_option_regex}[,]{0,1}[ ]{0,1}){0,1}"

  #Long option regex
  option_regex+="(${long_option_regex}){0,1}"

  #Check for default value
  option_regex+='([^\[]*)(\[default: ([a-zA-Z0-9]+)\]){0,1}.*$'

  for opt in "${command_options[@]}"; do
    # Check if option is valid
    if ! [[ ${opt} =~ ${option_regex} ]]; then
      bashop::logger::framework_error "Wrong pattern for option '${opt}'."
      exit 1
    fi

    local p_opts
    declare -A p_opts=()

    #Get short options name and agrument name
    p_opts["short_opt_name"]=${BASH_REMATCH[2]}
    p_opts["short_opt_repeatable"]=${BASH_REMATCH[3]}
    p_opts["short_opt_arg"]=''

    if [[ -n "${BASH_REMATCH[5]}" ]]; then
      p_opts["short_opt_arg"]=${BASH_REMATCH[5]}
    elif [[ -n "${BASH_REMATCH[6]}" ]]; then
      p_opts["short_opt_arg"]=${BASH_REMATCH[6]}
    fi

    #Get long options name and argument name
    p_opts["long_opt_name"]=${BASH_REMATCH[8]}
    p_opts["long_opt_repeatable"]=${BASH_REMATCH[9]}
    p_opts["long_opt_arg"]=''

    if [[ -n "${BASH_REMATCH[11]}" ]]; then
      p_opts["long_opt_arg"]=${BASH_REMATCH[11]}
    elif [[ -n "${BASH_REMATCH[12]}" ]]; then
      p_opts["long_opt_arg"]=${BASH_REMATCH[12]}
    fi

    #Get default option argument
    local default_option_arg=''

    if [[ -n "${BASH_REMATCH[15]}" ]]; then
      default_option_arg=${BASH_REMATCH[15]}
    fi

    local type_name=''
    local cur_opt=''

    #Set options
    if [[ -n "${p_opts["short_opt_name"]}" ]] && [[ -n "${p_opts["long_opt_name"]}" ]]; then
      #Repeatable
      if ( [[ -n "${p_opts["short_opt_repeatable"]}" ]] && ! [[ -n "${p_opts["long_opt_repeatable"]}" ]] ) ||
         ( ! [[ -n "${p_opts["short_opt_repeatable"]}" ]] && [[ -n "${p_opts["long_opt_repeatable"]}" ]] )
      then
        bashop::logger::framework_error "One of the option of '${opt}' is repeatable so both must be repeatable."
        exit 1
      fi

      #Arguments
      if ( [[ -n "${p_opts["short_opt_arg"]}" ]] && ! [[ -n "${p_opts["long_opt_arg"]}" ]] ) ||
         ( ! [[ -n "${p_opts["short_opt_arg"]}" ]] && [[ -n "${p_opts["long_opt_arg"]}" ]] )
      then
        bashop::logger::framework_error "One of the option of '${opt}' accepts an argument so both must accept one."
        exit 1
      fi

      opt_map["${p_opts["short_opt_name"]}"]=${p_opts["long_opt_name"]}
      type_name='long'
      cur_opt=${p_opts["long_opt_name"]}
    elif [[ -n "${p_opts["short_opt_name"]}" ]]; then
      type_name='short'
      cur_opt=${p_opts["short_opt_name"]}
      opt_map[${cur_opt}]=${cur_opt}
    elif [[ -n "${p_opts["long_opt_name"]}" ]]; then
      type_name='long'
      cur_opt=${p_opts["long_opt_name"]}
      opt_map[${cur_opt}]=${cur_opt}
    else
      bashop::logger::framework_error "Wrong pattern for option '${opt}'."
      exit 1
    fi

    if [[ -n "${p_opts["${type_name}_opt_repeatable"]}" ]]; then
      opt_repeatable[${cur_opt}]=true
    else
      opt_repeatable[${cur_opt}]=false
    fi

    if [[ -n "${p_opts["${type_name}_opt_arg"]}" ]]; then
      if [[ -n "${default_option_arg}" ]]; then
        opt_default_arg[${cur_opt}]=${default_option_arg}
      else
        opt_default_arg[${cur_opt}]=false
      fi
    fi
  done


  #---- Parese arguments ----

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

      if [[ ${opt_repeatable[${current_arg}]} ]]; then
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
}