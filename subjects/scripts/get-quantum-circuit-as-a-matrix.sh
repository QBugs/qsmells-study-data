#!/usr/bin/env bash
#
# ------------------------------------------------------------------------------
# This script processes a quantum circuit and produces a matrix where each row
# represents a quantum or a classic bit, each column represents a timestamp in
# the circuit, and each cell represents a quantum operation performed in the
# circuit.
#
# Usage:
# get-quantum-circuit-as-a-matrix.sh
#   --wrapper_name <name of the wrapper program to load and analyze, e.g., wrapper_ch04_02_teleport_fly>
#   [--transpile <bool, false by default>]
#   [--output_dir_path <path, e.g., ../data/generated/quantum-circuit-as-matrix>]
#   [help]
# ------------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null 2>&1 && pwd)"
source "$SCRIPT_DIR/../../utils/scripts/utils.sh" || exit 1

WRAPPERS_DIR_PATH="$SCRIPT_DIR/wrappers"
[ -d "$WRAPPERS_DIR_PATH" ] || die "[ERROR] $WRAPPERS_DIR_PATH does not exist!"

# ------------------------------------------------------------------------- Args

USAGE="Usage: ${BASH_SOURCE[0]} --wrapper_name <name of the wrapper program to load and analyze, e.g., wrapper_ch04_02_teleport_fly> [--transpile <bool, false by default>] [--output_dir_path <path, e.g., ../data/generated/quantum-circuit-as-matrix>] [help]"
if [ "$#" -ne "1" ] && [ "$#" -ne "2" ] && [ "$#" -ne "4" ] && [ "$#" -ne "6" ]; then
  die "$USAGE"
fi

WRAPPER_NAME=""
TRANSPILE=""
OUTPUT_DIR_PATH="$SCRIPT_DIR/../data/generated/quantum-circuit-as-matrix"

while [[ "$1" = --* ]]; do
  OPTION=$1; shift
  case $OPTION in
    (--wrapper_name)
      WRAPPER_NAME=$1;
      shift;;
    (--transpile)
      TRANSPILE=$1;
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

# Activate custom Python virtual environment
_activate_virtual_environment
# Augment Python's PATH with our custom wrappers
export PYTHONPATH="$WRAPPERS_DIR_PATH:$PYTHONPATH"

OUTPUT_FILE_PATH="$OUTPUT_DIR_PATH/$(echo $WRAPPER_NAME | sed 's|^wrapper_||').csv"
echo "[DEBUG] Going to process $WRAPPER_NAME (in $WRAPPER_FILE_PATH) and save it to $OUTPUT_FILE_PATH"

if [ "$TRANSPILE" == "" ]; then
  python "$SCRIPT_DIR/../../utils/scripts/quantum_circuit_to_binary_matrix.py" \
    --module-name "$WRAPPER_NAME" \
    --justify "left" \
    --output-file "$OUTPUT_FILE_PATH" || die "[ERROR] Failed to execute $WRAPPER_FILE_PATH!"
else
  python "$SCRIPT_DIR/../../utils/scripts/quantum_circuit_to_binary_matrix.py" \
    --module-name "$WRAPPER_NAME" \
    --justify "left" \
    --transpile-circuit \
    --output-file "$OUTPUT_FILE_PATH" || die "[ERROR] Failed to execute $WRAPPER_FILE_PATH!"
fi

# Deactivate custom Python virtual environment
_deactivate_virtual_environment

echo "DONE!"
exit 0

# EOF
