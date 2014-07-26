#!/usr/bin/env bash
set -euo pipefail

resolve_link() {
  $(type -p greadlink readlink | head -1) "$1"
}

abs_dirname() {
  local cwd="$(pwd)"
  local path="$1"

  while [ -n "$path" ]; do
    cd "${path%/*}"
    local name="${path##*/}"
    path="$(resolve_link "$name" || true)"
  done

  pwd
  cd "$cwd"
}

export _BASHOP_ROOT="$(abs_dirname "$0")"
export PATH="${_BASHOP_ROOT}:$PATH"

source ${_BASHOP_ROOT}/utils/echo.sh
source ${_BASHOP_ROOT}/utils/run_process.sh
source ${_BASHOP_ROOT}/utils/argument_parser.sh

#test
commands=(
  'com'
  'subcommand'
  'subsubcom'
)

command_arguments=(
  "version"
  "name"
)

declare -g -A command_options=(
  ["single-required:"]="Desc 1"
  ["single-optional?"]="Desc 2"
  ["single-repeatable+"]="Desc 3"
  ["r|required-opt:"]="Desc 4"
  ["o|optional-opt?"]="Desc 5"
  ["p|repeatable-opt+"]="Desc 6"
)

parse_arguments ${@}

echo "---- Args -----"

for key in "${!args[@]}"; do
  k=$(echo ${key} | grep -o '[a-z0-9\-]*')


  if [[ $(echo ${key} | grep -o '[\#]*') == "#" ]] && (key_exists "${k},#" args); then
    echo "|> ${k}"

    i=0
    while [[ ${i} -lt ${args["${k},#"]} ]] ; do
      echo "|==> ${args[${k},${i}]}"
      i=$[$i+1]
    done
  elif [[ $(echo ${key} | grep -o '[\,]*') == "" ]]; then
    echo "|> ${k}"
    echo "|==> ${args[${k}]}"
  fi
done

command="$1"
case "$command" in
"" | "-h" | "--help" )
  #exec help
  ;;
* )
  command_path="$(command -v "$command" || true)"

  if [ ! -x "$command_path" ]; then

    echo_fail "no such command \`$command'\n" >&2
    exit 1
  fi

  shift
  source "$command_path"
  _run "$@"
  ;;
esac