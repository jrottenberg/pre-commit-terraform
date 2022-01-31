#!/usr/bin/env bash
set -eo pipefail

# shellcheck disable=SC2155 # No way to assign to readonly variable in separate lines
readonly SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
# shellcheck source=_common.sh
. "$SCRIPT_DIR/_common.sh"

function main {
  common::initialize "$SCRIPT_DIR"
  common::parse_cmdline "$@"
  # shellcheck disable=SC2153 # False positive
  tfupdate_ "${ARGS[*]}"
}

#######################################################################
# Unique part of `common::per_dir_hook`. The function is executed in loop
# on each provided configuration.
# Outputs:
#   If failed - print out hook checks status
#######################################################################
function tfupdate_ {
  local -r args="$1"
  set -x
  echo $args
  # Get args settings
  IFS=";" read -r -a runs <<< "$args"
  echo $runs
  # pass the arguments to hook
  # shellcheck disable=SC2068 # hook fails when quoting is used ("$arg[@]")

  local exit_code=0

  for run in "${runs[@]}"; do
    echo $run
    tfupdate "${run}" . -r
    exit_code=$(( ? + exit_code ))
  done

  return "$exit_code"
}

[ "${BASH_SOURCE[0]}" != "$0" ] || main "$@"
