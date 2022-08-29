#!/usr/bin/env bash
#
# ------------------------------------------------------------------------------
# This script runs PySmell on a single program (i.e., Python file) and writes
# PySmell's output to the provided output file.
#
# Usage:
# run-pysmell.sh
#   --input_file_path <path, e.g., ../../tools/qiskit-terra/qiskit/algorithms/amplitude_amplifiers/grover.py>
#   --smell_metric <str, name of the smell metric to compute: PAR, MLOC, DOC, NBC, CLOC, NOC, LPAR, NOO, TNOC, TNOL, CNOC, NOFF, CNOO, LMC, LEC, DNC, NCT>
#   --output_file_path <path>
#   [help]
# ------------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null 2>&1 && pwd)"
source "$SCRIPT_DIR/../../utils/scripts/utils.sh" || exit 1

# ------------------------------------------------------------------------- Args

USAGE="Usage: ${BASH_SOURCE[0]} --input_file_path <path, e.g., ../../tools/qiskit-terra/qiskit/algorithms/amplitude_amplifiers/grover.py> --smell_metric <str, name of the smell metric to compute: PAR, MLOC, DOC, NBC, CLOC, NOC, LPAR, NOO, TNOC, TNOL, CNOC, NOFF, CNOO, LMC, LEC, DNC, NCT> --output_file_path <path> [help]"
if [ "$#" -ne "1" ] && [ "$#" -ne "6" ]; then
  die "$USAGE"
fi

INPUT_FILE_PATH=""
SMELL_METRIC=""
OUTPUT_FILE_PATH=""

while [[ "$1" = --* ]]; do
  OPTION=$1; shift
  case $OPTION in
    (--input_file_path)
      INPUT_FILE_PATH=$1;
      shift;;
    (--smell_metric)
      SMELL_METRIC=$1;
      shift;;
    (--output_file_path)
      OUTPUT_FILE_PATH=$1;
      shift;;
    (--help)
      echo "$USAGE"
      exit 0
    (*)
      die "$USAGE";;
  esac
done

# Check whether all arguments have been initialized
[ "$INPUT_FILE_PATH" != "" ]  || die "[ERROR] Missing --input_file_path argument!"
[ "$SMELL_METRIC" != "" ]     || die "[ERROR] Missing --smell_metric argument!"
[ "$OUTPUT_FILE_PATH" != "" ] || die "[ERROR] Missing --output_file_path argument!"
# Check whether input files exit and it is not empty
[ -s "$INPUT_FILE_PATH" ]     || die "[ERROR] $INPUT_FILE_PATH does not exist or it is empty!"
# TODO check whether SMELL_METRIC is valid

# Create output file
rm -f "$OUTPUT_FILE_PATH"
touch "$OUTPUT_FILE_PATH"

# ------------------------------------------------------------------------- Main

# Activate custom Python virtual environment
_activate_virtual_environment || die "[ERROR] Failed to activate virtual environment!"

echo "[DEBUG] Running PySmell on $INPUT_FILE_PATH"
start=$SECONDS
python -m pysmell \
  --smell-metric "$SMELL_METRIC" \
  --py-file-to-analyze "$INPUT_FILE_PATH" \
  --output-file "$OUTPUT_FILE_PATH" || die "[ERROR] Failed to run PySmell on $INPUT_FILE_PATH!"
[ -s "$OUTPUT_FILE_PATH" ] || die "[ERROR] $OUTPUT_FILE_PATH does not exist or it is empty!"
end=$SECONDS
runtime=$(echo "$end - $start" | bc -l)

# Augment CSV file with runtime information
SUBJECT_NAME="$(basename $INPUT_FILE_PATH | sed 's|.py$||')"
head -n1   "$OUTPUT_FILE_PATH" | sed 's|^|name,runtime,|' > "$OUTPUT_FILE_PATH.tmp"
tail -n +2 "$OUTPUT_FILE_PATH" | sed "s|^|$SUBJECT_NAME,$runtime,|g" >> "$OUTPUT_FILE_PATH.tmp"
mv "$OUTPUT_FILE_PATH.tmp" "$OUTPUT_FILE_PATH"

# Deactivate custom Python virtual environment
_deactivate_virtual_environment

echo "DONE!"
exit 0

# EOF
