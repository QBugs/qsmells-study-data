#!/usr/bin/env bash
#
# ------------------------------------------------------------------------------
# This script processes a quantum circuit and produces a matrix where each row
# represents a quantum or a classic bit and each column represents the operation
# performed in one or more quantum or a classic bits.
#
# Usage:
# get-quantum-circuit-as-a-matrix.sh
#   --wrapper_name <name of the wrapper program to load and analyze, e.g., wrapper_ch04_02_teleport_fly>
#   [--output_dir_path <path, e.g., ../data/generated/quantum-circuit-as-matrix>]
#   [help]
# ------------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null 2>&1 && pwd)"
source "$SCRIPT_DIR/../../utils/scripts/utils.sh" || exit 1

WRAPPERS_DIR_PATH="$SCRIPT_DIR/wrappers"
[ -d "$WRAPPERS_DIR_PATH" ] || die "[ERROR] $WRAPPERS_DIR_PATH does not exist!"

# ------------------------------------------------------------------------- Args

USAGE="Usage: ${BASH_SOURCE[0]} --wrapper_name <name of the wrapper program to load and analyze, e.g., wrapper_ch04_02_teleport_fly> [--output_dir_path <path, e.g., ../data/generated/quantum-circuit-as-matrix>] [help]"
if [ "$#" -ne "1" ] && [ "$#" -ne "2" ] && [ "$#" -ne "4" ]; then
  die "$USAGE"
fi

WRAPPER_NAME=""
OUTPUT_DIR_PATH="$SCRIPT_DIR/../data/generated/quantum-circuit-as-matrix"

while [[ "$1" = --* ]]; do
  OPTION=$1; shift
  case $OPTION in
    (--wrapper_name)
      WRAPPER_NAME=$1;
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
[ "$WRAPPER_NAME" != "" ]      || die "[ERROR] Missing --wrapper_name argument!"
[ "$OUTPUT_DIR_PATH" != "" ]   || die "[ERROR] Missing --output_dir_path argument!"
# Check whether input files exit and it is not empty
WRAPPER_FILE_PATH="$WRAPPERS_DIR_PATH/$WRAPPER_NAME.py"
[ -s "$WRAPPER_FILE_PATH" ]    || die "[ERROR] $WRAPPER_FILE_PATH does not exist or it is empty!"
# Create output directory
mkdir -p "$OUTPUT_DIR_PATH"    || die "[ERROR] Failed to create $OUTPUT_DIR_PATH!"

# ------------------------------------------------------------------------- Main

OUTPUT_FILE_PATH="$OUTPUT_DIR_PATH/$(echo $WRAPPER_NAME | sed 's|^wrapper_||').csv"
echo "[DEBUG] Going to process $WRAPPER_NAME (in $WRAPPER_FILE_PATH) and save it to $OUTPUT_FILE_PATH"

# Activate custom Python virtual environment
_activate_virtual_environment
# Augment Python's PATH with our custom wrappers
export PYTHONPATH="$WRAPPERS_DIR_PATH:$PYTHONPATH"
# Run script
python "$SCRIPT_DIR/../../utils/scripts/quantum_circuit_to_binary_matrix.py" \
  --module-name "$WRAPPER_NAME" \
  --output-file "$OUTPUT_FILE_PATH" || die "[ERROR] Failed to execute $WRAPPER_FILE_PATH!"
# Deactivate custom Python virtual environment
_deactivate_virtual_environment

echo "DONE!"
exit 0

# EOF
