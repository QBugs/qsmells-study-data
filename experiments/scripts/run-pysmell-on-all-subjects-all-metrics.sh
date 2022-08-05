#!/usr/bin/env bash
#
# ------------------------------------------------------------------------------
# This script runs PySmell on all programs (i.e., Python file of each program)
# and computes all smell metrics.
#
# Usage:
# run-pysmell-on-all-subjects-all-metrics.sh
#   [--subjects_file_path <path, e.g., ../data/subjects.csv>]
#   [--subjects_dir_path <path, e.g., ../../tools]
#   [--output_dir_path <path, e.g., ../data/generated/csmell-metrics>]
#   [help]
# ------------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null 2>&1 && pwd)"
source "$SCRIPT_DIR/../../utils/scripts/utils.sh" || exit 1

# ------------------------------------------------------------------------- Args

USAGE="Usage: ${BASH_SOURCE[0]} [--subjects_file_path <path, e.g., ../data/subjects.csv>] [--subjects_dir_path <path, e.g., ../../tools] [--output_dir_path <path, e.g., ../data/generated/csmell-metrics>] [help]"
if [ "$#" -ne "0" ] && [ "$#" -ne "1" ] && [ "$#" -ne "2" ] && [ "$#" -ne "4" ] && [ "$#" -ne "6" ]; then
  die "$USAGE"
fi

SUBJECTS_FILE_PATH="$SCRIPT_DIR/../../subjects/data/subjects.csv"
SUBJECTS_DIR_PATH="$SCRIPT_DIR/../../tools"
OUTPUT_DIR_PATH="$SCRIPT_DIR/../data/generated/csmell-metrics"

while [[ "$1" = --* ]]; do
  OPTION=$1; shift
  case $OPTION in
    (--subjects_file_path)
      SUBJECTS_FILE_PATH=$1;
      shift;;
    (--subjects_dir_path)
      SUBJECTS_DIR_PATH=$1;
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
[ "$SUBJECTS_FILE_PATH" != "" ] || die "[ERROR] Missing --subjects_file_path argument!"
[ "$SUBJECTS_DIR_PATH" != "" ]  || die "[ERROR] Missing --subjects_dir_path argument!"
[ "$OUTPUT_DIR_PATH" != "" ]    || die "[ERROR] Missing --output_dir_path argument!"
# Check whether input files exit and it is not empty
[ -s "$SUBJECTS_FILE_PATH" ]    || die "[ERROR] $SUBJECTS_FILE_PATH does not exist or it is empty!"
[ -d "$SUBJECTS_DIR_PATH" ]     || die "[ERROR] $SUBJECTS_DIR_PATH does not exist!"
# Create output directory
mkdir -p "$OUTPUT_DIR_PATH"

# ------------------------------------------------------------------------- Main

while read -r row; do
    origin=$(echo "$row" | cut -f1 -d',')
      name=$(echo "$row" | cut -f2 -d',')
  filepath=$(echo "$row" | cut -f3 -d',')

  python_file_path="$SUBJECTS_DIR_PATH/$filepath"
  [ -s "$python_file_path" ] || die "[ERROR] $python_file_path does not exist or it is empty!"

  for smell_metric in "PAR" "MLOC" "DOC" "NBC" "CLOC" "NOC" "LPAR" "NOO" "TNOC" "TNOL" "CNOC" "NOFF" "CNOO" "LMC" "LEC" "DNC" "NCT"; do
    output_file_path="$OUTPUT_DIR_PATH/$smell_metric/$name/data.csv"
    output_dir_path=$(echo "$output_file_path" | rev | cut -f2- -d'/' | rev)
    rm -rf "$output_dir_path"; mkdir -p "$output_dir_path"

    time bash "$SCRIPT_DIR/run-pysmell.sh" \
      --input_file_path "$python_file_path" \
      --smell_metric "$smell_metric" \
      --output_file_path "$output_file_path" || die "[ERROR] Failed to execute run-pysmell.sh on $python_file_path!"
  done

  break # FIXME remove me
done < <(tail -n +2 "$SUBJECTS_FILE_PATH")

# Collect all data generated by PySmell in a single CSV file
find "$OUTPUT_DIR_PATH" -mindepth 3 -maxdepth 3 -type f -name "data.csv" | head -n1 | xargs head -n1 > "$OUTPUT_DIR_PATH/data.csv"
find "$OUTPUT_DIR_PATH" -mindepth 3 -maxdepth 3 -type f -name "data.csv" -exec tail -n +2 {} \;     >> "$OUTPUT_DIR_PATH/data.csv"
[ -s "$OUTPUT_DIR_PATH/data.csv" ] || die "[ERROR] $OUTPUT_DIR_PATH/data.csv does not exist or it is empty!"

echo "DONE!"
exit 0

# EOF
