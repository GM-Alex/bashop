#!/usr/bin/env bash

bashop::command::show_help() {
  echo "Help"
}

bashop::command::parse_arguments() {
  #Declare global argument array
  declare -g -A args=()

  #Get function agruments
  local raw_command_arguments=("${!1}")
  local raw_command_options=("${!2}")
  local raw_arguments=("${!3}")

  #Regex for options
  local short_option_regex='(-[a-zA-Z]{1})([.]{3}){0,1}'
  short_option_regex+='( ([\<][a-z]+[\>])| ([A-Z]+)){0,1}'
  local long_option_regex='(--[a-zA-Z0-9\-]+)([.]{3}){0,1}'
  long_option_regex+='(=([\<][a-z]+[\>])| ([A-Z]+)){0,1}'

  #---- Command arguments ----
  local com_args_repeatable=false
  local com_args_required=()
  local com_args=()

  #Command regex
  local command_arg_regex='(([\<][a-zA-Z0-9]+[\>])([.]{3}){0,1})'
  local commmand_arg_requried_regex="^${command_arg_regex}$"
  local commmand_arg_optional_regex="^\[${command_arg_regex}\]$"

  #Get command arguments
  for command_argument in ${raw_command_arguments[@]}; do
    if [[ ${command_argument} =~ ${commmand_arg_requried_regex} ]] || [[ ${command_argument} =~ ${commmand_arg_optional_regex} ]]; then
      local com_arg_name=${BASH_REMATCH[2]}
      local com_arg_rep=${BASH_REMATCH[3]}

      if [[ ${command_argument} =~ ${commmand_arg_requried_regex} ]]; then
        com_args_required+=( ${com_arg_name} )
      fi

      com_args+=( ${com_arg_name} )

      if [[ ${com_args_repeatable} == false ]] && [[ -n "${com_arg_rep}" ]]; then
        com_args_repeatable=true
      elif [[ ${com_args_repeatable} == true ]]; then
        bashop::logger::framework_error "Only the last argument can be repeatable, but you have defined '${raw_command_arguments[@]}'."
        exit 1
      fi
    elif [[ ${command_argument} =~ ${short_option_regex} ]] || [[ ${command_argument} =~ ${long_option_regex} ]]; then
      raw_command_options+=( ${command_argument} )
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

  for opt in "${raw_command_options[@]}"; do
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

  local no_commands=${#_BASHOP_COMMAND[@]}
  local no_com_args=${#com_args[@]}
  local no_raw_arguments=${#raw_arguments[@]}
  local arg=''
  local current_arg=''
  local com_arg_counter=0
  local counter=0
  local req_param_name=''

  # Iterate over the raw argumgents
  while [[ ${counter} -lt ${no_raw_arguments} ]]; do
    arg=${raw_arguments[${counter}]}

    if [[ ${counter} -lt ${no_commands} ]] && !(bashop::utils::is_option ${arg}); then
      if [[ ${arg} != ${_BASHOP_COMMAND[${counter}]} ]]; then
        bashop::logger::framework_error "Unknown command '${arg}' called"
        exit 1
      fi
    elif (bashop::utils::is_option ${arg}); then
      #Check for valid option
      if (bashop::utils::key_exists ${arg} opt_map); then
        arg=${opt_map[${arg}]}
      else
        bashop::logger::error "Unkown option '${arg}'"
        exit 1
      fi

      local current_arg=${arg}

      #Set multiple args
      if [[ ${opt_repeatable[${current_arg}]} == true ]] && !(bashop::utils::key_exists "${current_arg},#" args); then
        args["${current_arg},#"]=0
      elif [[ ${opt_repeatable[${current_arg}]} == false ]] && !(bashop::utils::key_exists ${current_arg} args); then
        args[${current_arg}]=''
      elif (bashop::utils::key_exists ${current_arg} args) && [[ ${opt_repeatable[${current_arg}]} == false ]]; then
        bashop::logger::error "'${current_arg}' can't be multiple definied"
        exit 1
      fi

      #Check if accept arguments and grep them
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

        #Get argument
        if [[ ${opt_argument} == false ]] && [[ ${opt_default_arg["${current_arg}"]} != false ]]; then
          opt_argument=${opt_default_arg["${current_arg}"]}
        fi

        #Set default value if no is given or show error
        if [[ ${opt_argument} != false ]]; then
          if [[ ${opt_repeatable[${current_arg}]} == true ]]; then
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
    elif [[ ${com_arg_counter} -lt ${no_com_args} ]];then
      local req_param_name=${com_args[${com_arg_counter}]}
      args[${req_param_name}]=${arg}
      com_arg_counter=$((com_arg_counter + 1))
    else
      bashop::logger::error "Unknow argument '${arg}'"
      exit 1
    fi

    counter=$((counter + 1))
  done

  #Check if all requried args are set
  for com_arg_req in ${com_args_required[@]}; do
    if !(bashop::utils::key_exists ${com_arg_req} args); then
      bashop::logger::error "Missing required command argument '${com_arg_req}'"
      exit 1
    fi
  done

  #Everything done now set the args to read only
  readonly args
}