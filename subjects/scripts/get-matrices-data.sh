#!/usr/bin/env bash
#
# ------------------------------------------------------------------------------
# This script parses all quantum matrices (previous generated by the `get-quantum-circuit-as-a-matrix.sh`
# script) and collects the following information of each matrix:
#  - number of qubits
#  - number of clbits
#  - number of operations performed in the circuit
#
# Usage:
# get-matrices-data.sh
#   [--subjects_file_path <path, e.g., ../data/subjects.csv>]
#   [--matrices_dir_path <path, e.g., ../data/generated/quantum-circuit-as-matrix]
#   [--output_file_path <path, e.g., ../data/generated/matrices-data.csv>]
#   [help]
# ------------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null 2>&1 && pwd)"
source "$SCRIPT_DIR/../../utils/scripts/utils.sh" || exit 1

# ------------------------------------------------------------------------- Args

USAGE="Usage: ${BASH_SOURCE[0]} [--subjects_file_path <path, e.g., ../data/subjects.csv>] [--matrices_dir_path <path, e.g., ../data/generated/quantum-circuit-as-matrix] [--output_file_path <path, e.g., ../data/generated/matrices-data.csv>] [help]"
if [ "$#" -ne "0" ] && [ "$#" -ne "1" ] && [ "$#" -ne "2" ] && [ "$#" -ne "4" ] && [ "$#" -ne "6" ]; then
  die "$USAGE"
fi

SUBJECTS_FILE_PATH="$SCRIPT_DIR/../data/subjects.csv"
MATRICES_DIR_PATH="$SCRIPT_DIR/../data/generated/quantum-circuit-as-matrix"
OUTPUT_FILE_PATH="$SCRIPT_DIR/../data/generated/matrices-data.csv"

while [[ "$1" = --* ]]; do
  OPTION=$1; shift
  case $OPTION in
    (--subjects_file_path)
      SUBJECTS_FILE_PATH=$1;
      shift;;
    (--matrices_dir_path)
      MATRICES_DIR_PATH=$1;
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
[ "$SUBJECTS_FILE_PATH" != "" ] || die "[ERROR] Missing --subjects_file_path argument!"
[ "$MATRICES_DIR_PATH" != "" ]  || die "[ERROR] Missing --matrices_dir_path argument!"
[ "$OUTPUT_FILE_PATH" != "" ]   || die "[ERROR] Missing --output_file_path argument!"
# Check whether input files exit and it is not empty
[ -s "$SUBJECTS_FILE_PATH" ]    || die "[ERROR] $SUBJECTS_FILE_PATH does not exist or it is empty!"
[ -d "$MATRICES_DIR_PATH" ]     || die "[ERROR] $MATRICES_DIR_PATH does not exist!"
# Create output directory
rm -f "$OUTPUT_FILE_PATH"
echo "origin,name,path,num_qubits,num_clbits,num_ops" > "$OUTPUT_FILE_PATH" || die "[ERROR] Failed to create $OUTPUT_FILE_PATH!"

# ------------------------------------------------------------------------- Args

while read -r row; do
    origin=$(echo "$row" | cut -f1 -d',')
      name=$(echo "$row" | cut -f2 -d',')
  filepath=$(echo "$row" | cut -f3 -d',')

  matrix_file_path="$MATRICES_DIR_PATH/$name.csv"
  [ -s "$matrix_file_path" ] || continue

  num_qubits=$(tail -n +2 "$matrix_file_path" | grep "^q-" | wc -l)
  num_clbits=$(tail -n +2 "$matrix_file_path" | grep "^c-" | wc -l)
  num_ops=$(head -n1 "$matrix_file_path" | tr ';' '\n' | wc -l); num_ops=$((num_ops-1))

  echo "$origin,$name,$filepath,$num_qubits,$num_clbits,$num_ops" >> "$OUTPUT_FILE_PATH"
done < <(tail -n +2 "$SUBJECTS_FILE_PATH")

echo "DONE!"
exit 0

# EOF
