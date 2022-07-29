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

  # Augment Python's PATH with O'Reilly's samples/Qiskit directory
  OREILLY_SAMPLES_DIR="$UTILS_SCRIPT_DIR/../../tools/oreilly-qc.github.io/samples/Qiskit"
  [ -d "$OREILLY_SAMPLES_DIR" ] || die "[ERROR] $OREILLY_SAMPLES_DIR does not exist!"
  export PYTHONPATH="$OREILLY_SAMPLES_DIR:$PYTHONPATH"

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

# EOF
