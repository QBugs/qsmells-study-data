#!/usr/bin/env bash
#
# ------------------------------------------------------------------------------
# This script clones, by default, the GIT repository of all quantum projects
# defined in the [../data/quantum-computing-projects.csv](../data/quantum-computing-projects.csv)
# file.
#
# Usage:
# get-quantum-projects-repositories.sh
#   [--quantum_projects_csv_file_path <path, e.g., ../data/quantum-computing-projects.csv>]
#   [--output_dir_path <path, e.g., ../repositories>]
#   [help]
# ------------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null 2>&1 && pwd)"
source "$SCRIPT_DIR/../../utils/scripts/utils.sh" || exit 1

# ------------------------------------------------------------------------- Args

USAGE="Usage: ${BASH_SOURCE[0]} [--quantum_projects_csv_file_path <path, e.g., ../data/quantum-computing-projects.csv>] [--output_dir_path <path, e.g., ../repositories>] [help]"
if [ "$#" -ne "0" ] && [ "$#" -ne "1" ] && [ "$#" -ne "2" ] && [ "$#" -ne "4" ]; then
  die "$USAGE"
fi

QUANTUM_PROJECTS_CSV_FILE_PATH="$SCRIPT_DIR/../data/quantum-computing-projects.csv"
OUTPUT_DIR_PATH="$SCRIPT_DIR/../repositories"

while [[ "$1" = --* ]]; do
  OPTION=$1; shift
  case $OPTION in
    (--quantum_projects_csv_file_path)
      QUANTUM_PROJECTS_CSV_FILE_PATH=$1;
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
[ "$QUANTUM_PROJECTS_CSV_FILE_PATH" != "" ] || die "[ERROR] Missing --quantum_projects_csv_file_path argument!"
[ "$OUTPUT_DIR_PATH" != "" ]                || die "[ERROR] Missing --output_dir_path argument!"
# Check whether input files exit and it is not empty
[ -s "$QUANTUM_PROJECTS_CSV_FILE_PATH" ]    || die "[ERROR] $QUANTUM_PROJECTS_CSV_FILE_PATH does not exist or it is empty!"
# Create output directory
rm -rf "$OUTPUT_DIR_PATH"
mkdir -p "$OUTPUT_DIR_PATH"                 || die "[ERROR] Failed to create $OUTPUT_DIR_PATH!"

# ------------------------------------------------------------------------- Main

while read -r row; do

  clone_url=$(echo "$row" | cut -f2 -d',')
   name_dir=$(echo "$clone_url" | rev | cut -f1 -d'/' | cut -f2 -d'.' | rev)
    version=$(echo "$row" | cut -f3 -d',')

  # Clone it
  local_repository_dir_path="$OUTPUT_DIR_PATH/$name_dir"
  echo "Cloning $clone_url ($version) to $local_repository_dir_path"
  git clone "$clone_url" "$local_repository_dir_path" || die "[ERROR] Failed to clone $clone_url to $local_repository_dir_path!"
  [ -d "$local_repository_dir_path" ] || die "[ERROR] $local_repository_dir_path does not exist! Failed to clone $clone_url to $local_repository_dir_path!"

  # Get specific version of it
  pushd . > /dev/null 2>&1
  cd "$local_repository_dir_path"
    git checkout "$version" || "[ERROR] Failed to get $version of $clone_url!"
  popd > /dev/null 2>&1

done < <(tail -n +2 "$QUANTUM_PROJECTS_CSV_FILE_PATH") # project_name,project_clone_url,version,language

echo "DONE!"
exit 0

# EOF
