#!/usr/bin/env bash
#
# ------------------------------------------------------------------------------
# This script draws a quantum circuit in three different output types (ASCII,
# latex, and image).
#
# Usage:
# get-quantum-circuit-as-a-draw.sh
#   --wrapper_name <name of the wrapper program to load and analyze, e.g., grover>
#   [--output_dir_path <path, e.g., ../data/generated/quantum-circuit-as-draw>]
#   [help]
#
# Requirements:
# - [ImageMagick](https://imagemagick.org/index.php) installed and available
# ------------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null 2>&1 && pwd)"
source "$SCRIPT_DIR/../../utils/scripts/utils.sh" || exit 1

# -------------------------------------------------------------------------- Env

WRAPPERS_DIR_PATH="$SCRIPT_DIR/wrappers"
[ -d "$WRAPPERS_DIR_PATH" ] || die "[ERROR] $WRAPPERS_DIR_PATH does not exist!"

# Sanity check whether `convert` is available
convert --version > /dev/null 2>&1 || die "[ERROR] Failed to find the convert executable from the [ImageMagick](https://imagemagick.org/index.php) package."

# ------------------------------------------------------------------------- Args

USAGE="Usage: ${BASH_SOURCE[0]} --wrapper_name <name of the wrapper program to load and analyze, e.g., grover> [--output_dir_path <path, e.g., ../data/generated/quantum-circuit-as-draw>] [help]"
if [ "$#" -ne "1" ] && [ "$#" -ne "2" ] && [ "$#" -ne "4" ]; then
  die "$USAGE"
fi

WRAPPER_NAME=""
OUTPUT_DIR_PATH="$SCRIPT_DIR/../data/generated/quantum-circuit-as-draw"

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

# Activate custom Python virtual environment
_activate_virtual_environment
# Augment Python's PATH with our custom wrappers
export PYTHONPATH="$WRAPPERS_DIR_PATH:$PYTHONPATH"

_run_script() {
  local USAGE="Usage: ${FUNCNAME[0]} <output-type> <file-extension>"
  if [ "$#" != 2 ] ; then
    echo "$USAGE" >&2
    return 1
  fi

  output_type="$1"
  output_file_ext="$2"

  output_file_path="$OUTPUT_DIR_PATH/$(echo $WRAPPER_NAME | sed 's|^wrapper_||')$output_file_ext"
  echo "[DEBUG] Going to pretty-print $WRAPPER_NAME (in $WRAPPER_FILE_PATH) and save it to $output_file_path"
  python "$SCRIPT_DIR/../../utils/scripts/quantum_circuit_to_draw.py" \
    --module-name "$WRAPPER_NAME" \
    --output-type "$output_type" \
    --output-file "$output_file_path" || die "[ERROR] Failed to execute $WRAPPER_FILE_PATH!"

  if [ "$output_file_ext" == ".pdf" ]; then
    convert -density 300 "$output_file_path" -quality 100 $(echo "$output_file_path" | sed 's|.pdf$|.png|')
  fi
}

_run_script "text"         ".txt"
_run_script "latex_source" ".tex"
_run_script "mpl"          ".pdf"

# Deactivate custom Python virtual environment
_deactivate_virtual_environment

echo "DONE!"
exit 0

# EOF
