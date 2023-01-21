#!/usr/bin/env bash

UTILS_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null 2>&1 && pwd)"
USER_HOME_DIR="$(cd ~ && pwd)"

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8

#
# Print error message to the stdout and exit.
#
die() {
  echo "$@" >&2
  exit 1
}

#
# Activate python virtual environment.
#
_activate_virtual_environment() {
  local USAGE="Usage: ${FUNCNAME[0]}"
  if [ "$#" != 0 ] ; then
    echo "$USAGE" >&2
    return 1
  fi

  [ -d "$UTILS_SCRIPT_DIR/../../tools/env" ] || die "[ERROR] $UTILS_SCRIPT_DIR/../../tools/env does not exist and therefore no virtual environment could be activated!"
  source "$UTILS_SCRIPT_DIR/../../tools/env/bin/activate" || die "[ERROR] Failed to activate virtual environment!"
  python --version >&2

  # Augment Python's PATH with our custom made scripts
  export PYTHONPATH="$UTILS_SCRIPT_DIR:$PYTHONPATH"

  return 0
}

#
# Deactivate python virtual environment.
#
_deactivate_virtual_environment() {
  local USAGE="Usage: ${FUNCNAME[0]}"
  if [ "$#" != 0 ] ; then
    echo "$USAGE" >&2
    return 1
  fi

  deactivate || die "[ERROR] Failed to deactivate virtual environment!"

  return 0
}

#
# Given a relative path, this function converts it into a full/absolute path.
#
rel_to_abs_filename() {
  local USAGE="Usage: ${FUNCNAME[0]}"
  if [ "$#" != 1 ] ; then
    echo "$USAGE" >&2
    return 1
  fi

  rel_filename="$1"
  echo "$(cd "$(dirname "$rel_filename")" && pwd)/$(basename "$rel_filename")" || return 1

  return 0
}

# EOF
