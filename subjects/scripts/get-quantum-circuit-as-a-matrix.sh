#!/usr/bin/env bash
#
# ------------------------------------------------------------------------------
# This script processes a quantum circuit and produces a matrix where each row
# represents a quantum or a classic bit and each column represents the operation
# performed in one or more quantum or a classic bits.
#
# Usage:
# get-quantum-circuit-as-a-matrix.sh
#   --wrapper_file_path <path, e.g., wrappers/wrapper_ch04_02_teleport_fly.py>
#   --output_dir_path <path, e.g., ../data/generated/circuits/ch04_02_teleport_fly>
#   [help]
# ------------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null 2>&1 && pwd)"
source "$SCRIPT_DIR/../../utils/scripts/utils.sh" || exit 1

# ------------------------------------------------------------------------- Args

USAGE="Usage: ${BASH_SOURCE[0]} --wrapper_file_path <path, e.g., wrappers/wrapper_ch04_02_teleport_fly.py> --output_dir_path <path, e.g., ../data/generated/circuits/ch04_02_teleport_fly> [help]"
if [ "$#" -ne "1" ] && [ "$#" -ne "4" ]; then
  die "$USAGE"
fi

WRAPPER_FILE_PATH=""
OUTPUT_DIR_PATH=""

while [[ "$1" = --* ]]; do
  OPTION=$1; shift
  case $OPTION in
    (--wrapper_file_path)
      WRAPPER_FILE_PATH=$1;
      shift;;
    (--output_dir_path)
      OUTPUT_DIR_PATH=$1;
      shift;;
    (--help)
      echo "$USAGE"
      exit 0
    (*)
      die "$USAGE";;
  esac
done

# Check whether all arguments have been initialized
[ "$WRAPPER_FILE_PATH" != "" ] || die "[ERROR] Missing --wrapper_file_path argument!"
[ "$OUTPUT_DIR_PATH" != "" ]   || die "[ERROR] Missing --output_dir_path argument!"
# Check whether input files exit and it is not empty
[ -s "$WRAPPER_FILE_PATH" ]    || die "[ERROR] $WRAPPER_FILE_PATH does not exist or it is empty!"
# Create output directory
mkdir -p "$OUTPUT_DIR_PATH"    || die "[ERROR] Failed to create $OUTPUT_DIR_PATH!"

# ------------------------------------------------------------------------- Main

# TODO activate pyenv

# TODO run each wrapper

# TODO deactivate pyenv

echo "DONE!"
exit 0

# EOF
