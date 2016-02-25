#!/usr/bin/env bash

##########################################
# Shows the command help page
# Globals:
#   array args
# Arguments:
#   array raw_command
#   array raw_command_arguments (optional)
#   array raw_command_options (optional)
# Returns:
#   None
##########################################
bashop::command::__show_help() {
  # Check which arguments given and not empty
  local raw_command=("${!1}")
  local raw_command_arguments=()

  if [[ -n ${!2+1} ]]; then
    raw_command_arguments=("${!2}")
  fi

  local raw_command_options=()

  if [[ -n ${!3+1} ]]; then
    raw_command_options=("${!3}")
  fi

  # Print command usage
  local full_command="${raw_command[@]}"

  bashop::printer::echo "Usage:"
  bashop::printer::echo "  ${full_command[@]} [options] " false

  if [[ ${#raw_command_arguments[@]} -gt 0 ]]; then
    local full_arguments="${raw_command_arguments[@]}"
    bashop::printer::echo "${full_arguments}" false
  fi

  bashop::printer::echo "" "\n\n"

  # Print command options
  bashop::printer::echo "Options:"

  if [[ ${#raw_command_options[@]} -gt 0 ]]; then
    raw_command_options=( "${raw_command_options[@]}" "${_BASHOP_BUILD_IN_OPTIONS[@]}" )
  else
    raw_command_options=( "${_BASHOP_BUILD_IN_OPTIONS[@]}" )
  fi

  bashop::printer::help_formatter raw_command_options[@]
}

##########################################
# Parses and validates the given argument
# Globals:
#   array args
# Arguments:
#   array raw_command
#   array raw_command_arguments
#   array raw_command_options
#   array raw_arguments
# Returns:
#   None
##########################################
bashop::command::__parse_arguments() {
  # Declare global argument array
  declare -g -A args=()

  # Get function arguments
  local raw_command=("${!1}")

  local raw_command_arguments=()

  if [[ -n ${!2+1} ]]; then
    local raw_command_arguments=("${!2}")
  fi

  local raw_command_options=()

  if [[ -n ${!3+1} ]]; then
    raw_command_options=("${!3}")
  fi

  local raw_arguments=("${!4}")

  # Regex for options
  local short_option_regex='(-[a-zA-Z]{1})([.]{3}){0,1}'
  short_option_regex+='( ([\<][a-z]+[\>])| ([A-Z]+)){0,1}'
  local long_option_regex='(--[a-zA-Z0-9][a-zA-Z0-9\-]+)([.]{3}){0,1}'
  long_option_regex+='(=([\<][a-z]+[\>])| ([A-Z]+)){0,1}'


  # ---- Command arguments ----

  local com_args_repeatable=false
  local com_args_required=()
  local com_args=()

  # Command regex
  local command_arg_regex='(([\<][a-zA-Z0-9]+[\>])([.]{3}){0,1})'
  local command_arg_required_regex="^${command_arg_regex}$"
  local command_arg_optional_regex="^\[${command_arg_regex}\]$"

  # Get command arguments
  local command_argument

  if [[ ${#raw_command_arguments[@]} -gt 0 ]]; then
    for command_argument in "${raw_command_arguments[@]}"; do
      if [[ ${command_argument} =~ ${command_arg_required_regex} ]] || [[ ${command_argument} =~ ${command_arg_optional_regex} ]]; then
        local com_arg_name=${BASH_REMATCH[2]}
        local com_arg_rep=${BASH_REMATCH[3]}

        if [[ ${command_argument} =~ ${command_arg_required_regex} ]]; then
          com_args_required+=( ${com_arg_name} )
        fi

        com_args+=( ${com_arg_name} )

        if [[ ${com_args_repeatable} == false ]] && [[ -n "${com_arg_rep}" ]]; then
          com_args_repeatable=true
        elif [[ ${com_args_repeatable} == true ]]; then
          bashop::printer::__framework_error "Only the last argument can be repeatable, but you have defined '${raw_command_arguments[@]}'."
          exit 1
        fi
      elif [[ ${command_argument} =~ ${short_option_regex} ]] || [[ ${command_argument} =~ ${long_option_regex} ]]; then
        raw_command_options+=( ${command_argument} )
      fi
    done
  fi

  # ---- Command options ----

  # Get defined options
  declare -A opt_map=()
  declare -A opt_default_arg=()
  local opt_map opt_default_arg

  # Short option regex
  local option_regex+="^(${short_option_regex}[,]{0,1}[ ]{0,1}){0,1}"

  # Long option regex
  option_regex+="(${long_option_regex}){0,1}"

  # Check for default value
  option_regex+='([^\[]*)(\[default: ([a-zA-Z0-9]+)\]){0,1}.*$'

  local opt
  if [[ ${#raw_command_options[@]} -gt 0 ]]; then
    for opt in "${raw_command_options[@]}"; do
      # Check if option is valid
      if ! [[ ${opt} =~ ${option_regex} ]]; then
        bashop::printer::__framework_error "Wrong pattern for option '${opt}'."
        exit 1
      fi

      declare -A p_opts=()
      local p_opts

      # Get short options name and argument name
      p_opts["short_opt_name"]=${BASH_REMATCH[2]}
      p_opts["short_opt_repeatable"]=${BASH_REMATCH[3]}
      p_opts["short_opt_arg"]=''

      if [[ -n "${BASH_REMATCH[5]}" ]]; then
        p_opts["short_opt_arg"]=${BASH_REMATCH[5]}
      elif [[ -n "${BASH_REMATCH[6]}" ]]; then
        p_opts["short_opt_arg"]=${BASH_REMATCH[6]}
      fi

      # Get long options name and argument name
      p_opts["long_opt_name"]=${BASH_REMATCH[8]}
      p_opts["long_opt_repeatable"]=${BASH_REMATCH[9]}
      p_opts["long_opt_arg"]=''

      if [[ -n "${BASH_REMATCH[11]}" ]]; then
        p_opts["long_opt_arg"]=${BASH_REMATCH[11]}
      elif [[ -n "${BASH_REMATCH[12]}" ]]; then
        p_opts["long_opt_arg"]=${BASH_REMATCH[12]}
      fi

      # Get default option argument
      local default_option_arg=''

      if [[ -n "${BASH_REMATCH[15]}" ]]; then
        default_option_arg=${BASH_REMATCH[15]}
      fi

      local type_name=''
      local cur_opt=''

      # Set options
      if [[ -n "${p_opts["short_opt_name"]}" ]] && [[ -n "${p_opts["long_opt_name"]}" ]]; then
        # Repeatable
        if ( [[ -n "${p_opts["short_opt_repeatable"]}" ]] && ! [[ -n "${p_opts["long_opt_repeatable"]}" ]] ) ||
           ( ! [[ -n "${p_opts["short_opt_repeatable"]}" ]] && [[ -n "${p_opts["long_opt_repeatable"]}" ]] )
        then
          bashop::printer::__framework_error "One of the option of '${opt}' is repeatable so both must be repeatable."
          exit 1
        fi

        # Arguments
        if ( [[ -n "${p_opts["short_opt_arg"]}" ]] && ! [[ -n "${p_opts["long_opt_arg"]}" ]] ) ||
           ( ! [[ -n "${p_opts["short_opt_arg"]}" ]] && [[ -n "${p_opts["long_opt_arg"]}" ]] )
        then
          bashop::printer::__framework_error "One of the option of '${opt}' accepts an argument so both must accept one."
          exit 1
        fi

        opt_map["${p_opts["short_opt_name"]}"]=${p_opts["long_opt_name"]}
        type_name='long'
        cur_opt=${p_opts["long_opt_name"]}
      elif [[ -n "${p_opts["short_opt_name"]}" ]]; then
        type_name='short'
        cur_opt=${p_opts["short_opt_name"]}
      elif [[ -n "${p_opts["long_opt_name"]}" ]]; then
        type_name='long'
        cur_opt=${p_opts["long_opt_name"]}
      else
        bashop::printer::__framework_error "Wrong pattern for option '${opt}'."
        exit 1
      fi

      if [[ -n "${p_opts["${type_name}_opt_repeatable"]}" ]]; then
        args["${cur_opt},#"]=0
      else
        args[${cur_opt}]=''
      fi

      if [[ -n "${p_opts["${type_name}_opt_arg"]}" ]]; then
        if [[ -n "${default_option_arg}" ]]; then
          opt_default_arg[${cur_opt}]=${default_option_arg}
        else
          opt_default_arg[${cur_opt}]=''
        fi
      fi
    done
  fi

  # ---- Parse arguments ----

  local no_commands=${#raw_command[@]}
  local no_com_args=${#com_args[@]}
  local no_raw_arguments=${#raw_arguments[@]}
  local arg=''
  local current_arg=''
  local com_arg_counter=0
  local counter=0
  local req_param_name=''
  local double_dash=false

  # Iterate over the raw arguments
  while [[ ${counter} -lt ${no_raw_arguments} ]]; do
    arg=${raw_arguments[${counter}]}

    if [[ ${counter} -lt ${no_commands} ]] && !(bashop::utils::is_option ${arg}); then
      if [[ ${arg} != ${raw_command[${counter}]} ]]; then
        bashop::printer::__framework_error "Unknown command '${arg}' called"
        exit 1
      fi
    elif [[ ${arg} == '--' ]]; then
      double_dash=true
      args[${arg}]=''
    elif [[ ${double_dash} == true ]]; then
      args["--"]+=${arg}
      args["--"]+=' '
    elif (bashop::utils::is_option ${arg}); then
      local opt_argument=false

      if [[ ${arg} =~ (--[a-zA-Z0-9][a-zA-Z0-9\-]+)=(.*) ]]; then
        arg=${BASH_REMATCH[1]}
        opt_argument=${BASH_REMATCH[2]}
      fi

      # Check for valid option
      if (bashop::utils::key_exists ${arg} opt_map); then
        arg=${opt_map[${arg}]}
      elif !(bashop::utils::key_exists ${arg} args); then
        bashop::printer::error "Unkown option '${arg}'"
        exit 1
      fi

      local current_arg=${arg}

      # Check if arg is already set
      if !(bashop::utils::key_exists "${current_arg},#" args); then
        if [[ -n ${args["${current_arg}"]} ]]; then
          bashop::printer::error "'${current_arg}' can't be multiple defined"
          exit 1
        else
          args[${current_arg}]=true
        fi
      fi

      # Check if accept arguments and grep them
      if (bashop::utils::key_exists "${current_arg}" opt_default_arg); then
        local next=$((counter + 1))

        if [[ ${next} -lt ${no_raw_arguments} ]]; then
          arg=${raw_arguments[${next}]}

          if [[ -n "${arg}" ]] && !(bashop::utils::is_option ${arg}); then
            opt_argument=${arg}
            counter=${next}
          fi
        fi

        # Get argument
        if [[ ${opt_argument} == false ]] && [[ ${opt_default_arg["${current_arg}"]} != false ]]; then
          opt_argument=${opt_default_arg["${current_arg}"]}
        fi

        # Set default value if no is given or show error
        if [[ -n ${opt_argument} ]]; then
          if (bashop::utils::key_exists "${current_arg},#" args); then
            local no_opt_args=${args["${current_arg},#"]}
            args["${current_arg},${no_opt_args}"]="${opt_argument}"
            args["${current_arg},#"]=$((no_opt_args+1))
          else
            args[${current_arg}]="${opt_argument}"
          fi
        else
          bashop::printer::error "Missing required argument for option '${current_arg}'"
          exit 1
        fi
      fi
    elif [[ ${com_arg_counter} -lt ${no_com_args} ]] || [[ ${com_args_repeatable} == true ]]; then
      local req_param_name=${com_args[${com_arg_counter}]}

      if [[ ${com_arg_counter} -eq $((no_com_args - 1)) ]] && [[ ${com_args_repeatable} == true ]]; then
        local no_opt_args=0

        if (bashop::utils::key_exists "${req_param_name},#" args); then
          no_opt_args=${args["${req_param_name},#"]}
        fi

        args["${req_param_name},${no_opt_args}"]="${arg}"
        args["${req_param_name},#"]=$((no_opt_args+1))
      else
        args[${req_param_name}]=${arg}
        com_arg_counter=$((com_arg_counter + 1))
      fi
    else
      bashop::printer::error "Unknown argument '${arg}'"
      exit 1
    fi

    counter=$((counter + 1))
  done

  # Check if all required args are set
  local com_arg_req

  if [[ ${#com_args_required[@]} -gt 0 ]]; then
    for com_arg_req in "${com_args_required[@]}"; do
      if !(bashop::utils::key_exists ${com_arg_req} args); then
        bashop::printer::error "Missing required command argument '${com_arg_req}'"
        exit 1
      fi
    done
  fi

  # Everything done now set the args to read only
  readonly args
}