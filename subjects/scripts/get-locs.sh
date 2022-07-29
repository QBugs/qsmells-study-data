#!/usr/bin/env bash
#
# ------------------------------------------------------------------------------
# This script ...
#
# Usage:
# get-locs.sh
#   [--subjects_file_path <path, e.g., ../data/subjects.csv>]
#   [--output_file_path <path, e.g., ../data/generated/subjects-locs.csv>]
#   [help]
# ------------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null 2>&1 && pwd)"
source "$SCRIPT_DIR/../../utils/scripts/utils.sh" || exit 1

# -------------------------------------------------------------------------- Env

SUBJECTS_ROOT_DIR_PATH="$SCRIPT_DIR/../../tools"
[ -d "$SUBJECTS_ROOT_DIR_PATH" ] || die "[ERROR] $SUBJECTS_ROOT_DIR_PATH does not exist!"

CLOC_EXEC="$SCRIPT_DIR/../../tools/cloc"
[ -s "$CLOC_EXEC" ] || die "[ERROR] $CLOC_EXEC does not exist or it is empty!"

# ------------------------------------------------------------------------- Args

USAGE="Usage: ${BASH_SOURCE[0]} [--subjects_file_path <path, e.g., ../data/subjects.csv>] [--output_file_path <path, e.g., ../data/generated/subjects-locs.csv>] [help]"
if [ "$#" -ne "0" ] && [ "$#" -ne "1" ] && [ "$#" -ne "2" ] && [ "$#" -ne "4" ]; then
  die "$USAGE"
fi

SUBJECTS_FILE_PATH="../data/subjects.csv"
OUTPUT_FILE_PATH="$SCRIPT_DIR/../data/generated/subjects-locs.csv"

while [[ "$1" = --* ]]; do
  OPTION=$1; shift
  case $OPTION in
    (--subjects_file_path)
      SUBJECTS_FILE_PATH=$1;
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
[ "$OUTPUT_FILE_PATH" != "" ]   || die "[ERROR] Missing --output_file_path argument!"
# Check whether input files exit and it is not empty
[ -s "$SUBJECTS_FILE_PATH" ]    || die "[ERROR] $SUBJECTS_FILE_PATH does not exist or it is empty!"
# Create output directory
rm -f "$OUTPUT_FILE_PATH"
echo "origin,name,path,lines_of_code" > "$OUTPUT_FILE_PATH" || die "[ERROR] Failed to create $OUTPUT_FILE_PATH!"

# ------------------------------------------------------------------------- Args

while read -r row; do
    origin=$(echo "$row" | cut -f1 -d',')
      name=$(echo "$row" | cut -f2 -d',')
  filepath=$(echo "$row" | cut -f3 -d',')
  full_filepath="$SUBJECTS_ROOT_DIR_PATH/$filepath"
  [ -s "$full_filepath" ] || die "[ERROR] $full_filepath does not exist or it is empty!"

  lines_of_code=$(perl "$CLOC_EXEC" --csv --hide-rate --quiet --by-file "$full_filepath" | grep "$full_filepath" | rev | cut -f1 -d',' | rev)
  echo "$origin,$name,$filepath,$lines_of_code" >> "$OUTPUT_FILE_PATH"
done < <(tail -n +2 "$SUBJECTS_FILE_PATH")

echo "DONE!"
exit 0

# EOF
