#!/usr/bin/env bash
#
# ------------------------------------------------------------------------------
# This script runs the [Python Change Miner](https://github.com/JetBrains-Research/python-change-miner)
# tool on the set of Python quantum computing projects defined in the
# [../../subjects/data/quantum-computing-projects.csv](../../subjects/data/quantum-computing-projects.csv)
# file.
#
# Usage:
# run-python-change-miner.sh
#   [--repositories_dir_path <path, e.g., ../../subjects/repositories]
#   --output_dir_path <path, e.g., ../data/generated/change-patterns-by-python-change-miner>
#   [help]
# ------------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null 2>&1 && pwd)"
source "$SCRIPT_DIR/../../utils/scripts/utils.sh" || exit 1

# -------------------------------------------------------------------------- Env

PYTHON_CHANGE_MINER_DIR_PATH="$SCRIPT_DIR/../../tools/python-change-miner"
PYTHON_CHANGE_MINER_DIR_PATH="$(cd "$PYTHON_CHANGE_MINER_DIR_PATH" > /dev/null 2>&1 && pwd)" # Make it absolute
[ -d "$PYTHON_CHANGE_MINER_DIR_PATH" ] || die "[ERROR] $PYTHON_CHANGE_MINER_DIR_PATH does not exist!"

export GUMTREE_PYTHON_BIN=python
export GUMTREE_PYPARSER_PATH="$PYTHON_CHANGE_MINER_DIR_PATH/external/pythonparser_3.py"
[ -s "$GUMTREE_PYPARSER_PATH" ] || die "[ERROR] $GUMTREE_PYPARSER_PATH does not exist or it is empty!"
export GUMTREE_BIN_PATH="$PYTHON_CHANGE_MINER_DIR_PATH/external/compiled/gumtree-2.1.2/bin/gumtree"
[ -s "$GUMTREE_BIN_PATH" ] || die "[ERROR] $GUMTREE_BIN_PATH does not exist or it is empty!"

# ------------------------------------------------------------------------- Args

USAGE="Usage: ${BASH_SOURCE[0]} [--repositories_dir_path <path, e.g., ../../subjects/repositories] --output_dir_path <path, e.g., ../data/generated/change-patterns-by-python-change-miner> [help]"
if [ "$#" -ne "1" ] && [ "$#" -ne "2" ] && [ "$#" -ne "4" ]; then
  die "$USAGE"
fi

REPOSITORIES_DIR_PATH="$SCRIPT_DIR/../../subjects/repositories"
OUTPUT_DIR_PATH=""

while [[ "$1" = --* ]]; do
  OPTION=$1; shift
  case $OPTION in
    (--projects_file_path)
      PROJECTS_FILE_PATH=$1;
      shift;;
    (--repositories_dir_path)
      REPOSITORIES_DIR_PATH=$1;
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
[ "$REPOSITORIES_DIR_PATH" != "" ] || die "[ERROR] Missing --repositories_dir_path argument!"
[ "$OUTPUT_DIR_PATH" != "" ]       || die "[ERROR] Missing --output_dir_path argument!"
# Check whether REPOSITORIES_DIR_PATH exits
[ -d "$REPOSITORIES_DIR_PATH" ]    || die "[ERROR] $REPOSITORIES_DIR_PATH does not exist!  Did you run \`bash get-quantum-projects-repositories.sh\` in the <ROOT>/subjects/scripts directory?"
REPOSITORIES_DIR_PATH="$(cd "$REPOSITORIES_DIR_PATH" > /dev/null 2>&1 && pwd)" # Make it absolute
# Create output directory (in case it does not exist)
mkdir -p "$OUTPUT_DIR_PATH"        || die "[ERROR] Failed to create $OUTPUT_DIR_PATH!"
OUTPUT_DIR_PATH="$(cd "$OUTPUT_DIR_PATH" > /dev/null 2>&1 && pwd)" # Make it absolute

CHANGE_GRAPHS_DIR_PATH="$OUTPUT_DIR_PATH/change-graphs"
mkdir -p "$CHANGE_GRAPHS_DIR_PATH"

PATTERNS_DIR_PATH="$OUTPUT_DIR_PATH/change-patterns"
mkdir -p "$PATTERNS_DIR_PATH"

LOG_FILE="$OUTPUT_DIR_PATH/python-change-miner.log"
rm -f "$LOG_FILE"

# ------------------------------------------------------------------------- Main

# Get configuration file
        conf_file_path="$PYTHON_CHANGE_MINER_DIR_PATH/conf/settings.json"
example_conf_file_path="$PYTHON_CHANGE_MINER_DIR_PATH/conf/settings.json.example"
[ -s "$example_conf_file_path" ] || die "[ERROR] $example_conf_file_path does not exist or it is empty!"
rm -f "$conf_file_path"; cp "$example_conf_file_path" "$conf_file_path"
# Set some properties
sed -i "s|\"gumtree_bin_path\": str,|\"gumtree_bin_path\": \"$GUMTREE_BIN_PATH\",|g" "$conf_file_path" || die "[ERROR] Failed to set gumtree_bin_path property!"
sed -i "s|\"git_repositories_dir\": str,|\"git_repositories_dir\": \"$REPOSITORIES_DIR_PATH\",|g" "$conf_file_path" || die "[ERROR] Failed to set git_repositories_dir property!"
sed -i "s|\"change_graphs_storage_dir\": str,|\"change_graphs_storage_dir\": \"$CHANGE_GRAPHS_DIR_PATH\",|g" "$conf_file_path" || die "[ERROR] Failed to set change_graphs_storage_dir property!"
sed -i "s|\"patterns_output_dir\": str,|\"patterns_output_dir\": \"$PATTERNS_DIR_PATH\",|g" "$conf_file_path" || die "[ERROR] Failed to set patterns_output_dir property!"
sed -i "s|\"patterns_output_details\": false,|\"patterns_output_details\": true,|g" "$conf_file_path" || die "[ERROR] Failed to set patterns_output_details property!"
sed -i "s|\"patterns_full_print\": false,|\"patterns_full_print\": true,|g" "$conf_file_path" || die "[ERROR] Failed to set patterns_full_print property!"
sed -i "s|\"logger_file_path\": \"miner.log\",|\"logger_file_path\": \"$LOG_FILE\",|g" "$conf_file_path" || die "[ERROR] Failed to set logger_file_path property!"
sed -i "s|\"logger_file_log_level\": \"INFO\",|\"logger_file_log_level\": \"WARNING\",|g" "$conf_file_path" || die "[ERROR] Failed to set logger_file_log_level property!"
# Remove some other properties that are optional
sed -i "s|\"traverse_min_date\": str?,||g" "$conf_file_path" || die "[ERROR] Failed to remove traverse_min_date property!"
sed -i "s|\"patterns_min_date\": str?,||g" "$conf_file_path" || die "[ERROR] Failed to remove patterns_min_date property!"
sed -i "s|\"stackimpact_agent_key\": str?||g" "$conf_file_path" || die "[ERROR] Failed to remove stackimpact_agent_key property!"
# Fix JSON, as some properties got removed
sed -i "s|\"use_stackimpact\": false,|\"use_stackimpact\": false|g" "$conf_file_path" || die "[ERROR] Failed to fix use_stackimpact property!"

export PATH="$SCRIPT_DIR/../../tools/graphviz-2.48.0/local-bin/bin:$PATH"

_activate_virtual_environment || die
  pushd . > /dev/null 2>&1
  cd "$PYTHON_CHANGE_MINER_DIR_PATH"
    # Mine change graphs
    python main.py collect-cgs || die "[ERROR] python-change-miner failed to mine all change graphs!"
    # Search for patterns in the change graphs
    python main.py patterns || die "[ERROR] python-change-miner failed to search for patterns in the change graphs!"
  popd > /dev/null 2>&1
_deactivate_virtual_environment || die

echo "DONE!"
exit 0

# EOF
