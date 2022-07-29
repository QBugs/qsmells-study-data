#!/usr/bin/env bash
#
# ------------------------------------------------------------------------------
# This script downloads and sets up the following tools:
#   - [Simple Python Version Management: pyenv](https://github.com/pyenv/pyenv)
#     and [Virtualenv](https://virtualenv.pypa.io)
#   - [PySmell](https://github.com/QBugs/PySmell)
#   - [O'Reilly Code samples for Programming Quantum Computers](https://github.com/oreilly-qc/oreilly-qc.github.io)
#   - [Qiskit](https://github.com/Qiskit)
#   - [Cloc](https://github.com/AlDanial/cloc)
#   - [R](https://www.r-project.org)
#
# Usage:
# get-tools.sh
#
# ------------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null 2>&1 && pwd)"
source "$SCRIPT_DIR/../utils/scripts/utils.sh" || exit 1

# ------------------------------------------------------------------------- Deps

# Check whether 'wget' is available
wget --version > /dev/null 2>&1 || die "[ERROR] Could not find 'wget' to download all dependencies. Please install 'wget' and re-run the script."

# Check whether 'git' is available
git --version > /dev/null 2>&1 || die "[ERROR] Could not find 'git' to clone git repositories. Please install 'git' and re-run the script."

# Check whether 'Rscript' is available
Rscript --version > /dev/null 2>&1 || die "[ERROR] Could not find 'Rscript' to perform, e.g., statistical analysis. Please install 'Rscript' and re-run the script."

# ------------------------------------------------------------------------- Util

_install_python_version_x() {
  local USAGE="Usage: ${FUNCNAME[0]} <major> <minor> <micro>"
  if [ "$#" != 3 ] ; then
    echo "$USAGE" >&2
    return 1
  fi

  local major="$1"
  local minor="$2"
  local micro="$3"

  pyenv install -v "$major.$minor.$micro"
  if [ "$?" -ne "0" ]; then
    echo "[ERROR] Failed to install Python $major.$minor.$micro with pyenv.  Most likely reason is due to OS depends not being installed/available." >&2

    echo "" >&2
    echo "On Ubuntu/Debian please install the following dependencies:" >&2
    echo "sudo apt-get install -y make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev python-openssl" >&2

    echo "" >&2
    echo "On Fedora/CentOS/RHEL please install the following dependencies:" >&2
    echo "sudo yum install zlib-devel bzip2 bzip2-devel readline-devel sqlite sqlite-devel openssl-devel xz xz-devel libffi-devel" >&2

    echo "" >&2
    echo "On openSUSE please install the following dependencies:" >&2
    echo "zypper in zlib-devel bzip2 libbz2-devel libffi-devel libopenssl-devel readline-devel sqlite3 sqlite3-devel xz xz-devel" >&2

    echo "" >&2
    echo "On MacOS please install the following dependencies using the [homebrew package management system](https://brew.sh):" >&2
    echo "brew install openssl readline sqlite3 xz zlib" >&2
    echo "When running Mojave or higher (10.14+) you will also need to install the additional [SDK headers](https://developer.apple.com/documentation/xcode_release_notes/xcode_10_release_notes#3035624):" >&2
    echo "sudo installer -pkg /Library/Developer/CommandLineTools/Packages/macOS_SDK_headers_for_macOS_10.14.pkg -target /" >&2

    die
  fi

  # Switch to the version just installed
  pyenv local "$major.$minor.$micro" || die "[ERROR] Python $major.$minor.$micro is not available to pyenv!"

  python_version=$(python --version 2>&1)
  if [ "$python_version" != "Python $major.$minor.$micro" ]; then
    die "[ERROR] System is still using '$python_version' instead of $major.$minor.$micro!"
  fi

  # Ensure pip, setuptools, and wheel are up to date
  pip install --upgrade pip setuptools wheel || die "[ERROR] Failed to upgrade 'pip', 'setuptools', and 'wheel'!"

  # Check whether the version just installed is working properly
  python -m test || die "[ERROR] Python $major.$minor.$micro is not working properly!"

  # Disable/Unload the version just installed
  rm ".python-version" || die "[ERROR] Failed to remove '.python-version!'"

  return 0
}

# ------------------------------------------------------------------------- Main

#
# Get PyEnv
# https://realpython.com/intro-to-pyenv
#

echo ""
echo "Setting up pyenv..."

PYENV_DIR="$SCRIPT_DIR/pyenv"

# Remove any previous file and directory
rm -rf "$PYENV_DIR"

git clone https://github.com/pyenv/pyenv.git "$PYENV_DIR"
if [ "$?" -ne "0" ] || [ ! -d "$PYENV_DIR" ]; then
  die "[ERROR] Clone of 'pyenv' failed!"
fi

pushd . > /dev/null 2>&1
cd "$PYENV_DIR"
  # Switch to 'v2.3.2' branch/tag
  git checkout v2.3.2 || die "[ERROR] Branch/Tag 'v2.3.2' not found!"
popd > /dev/null 2>&1

export PYENV_ROOT="$PYENV_DIR"
export PATH="$PYENV_ROOT/bin:$PATH"

# Check whether 'pyenv' is (now) available
pyenv --version > /dev/null 2>&1 || die "[ERROR] Could not find 'pyenv' to setup Python's virtual environment!"
# Init it
eval "$(pyenv init --path)" || die "[ERROR] Failed to init pyenv!"

#
# Install required Python version
#

echo ""
echo "Installing required Python versions..."

# Install v3.8.0
_install_python_version_x "3" "7" "8" || die

#
# Get Virtualenv
# https://virtualenv.pypa.io
#

echo ""
echo "Installing up virtualenv..."

# Switch to installed version
pyenv local "3.7.8"                             || die "[ERROR] Failed to load Python v3.7.8!"
# Install virtualenv
pip install virtualenv                          || die "[ERROR] Failed to install 'virtualenv'!"
# Runtime sanity check
virtualenv --version > /dev/null 2>&1           || die "[ERROR] Could not find 'virtualenv'!"
# Create virtual environment
rm -rf "$SCRIPT_DIR/env"
virtualenv -p $(which python) "$SCRIPT_DIR/env" || die "[ERROR] Failed to create virtual environment!"
# Activate virtual environment
source "$SCRIPT_DIR/env/bin/activate"           || die "[ERROR] Failed to activate virtual environment!"
# Ensure pip, setuptools, and wheel are up to date
pip install --upgrade pip setuptools wheel      || die "[ERROR] Failed to upgrade 'pip', 'setuptools', and 'wheel'!"
# Deactivate virtual environment
deactivate                                      || die "[ERROR] Failed to deactivate virtual environment!"
# Revert to system Python version
rm ".python-version"                            || die

#
# Get PySmell
#
echo ""
echo "Setting up PySmell..."

PYSMELL_DIR_PATH="$SCRIPT_DIR/pysmell"

# Remove any previous file and directory
rm -rf "$PYSMELL_DIR_PATH"

git clone https://github.com/QBugs/PySmell.git "$PYSMELL_DIR_PATH"
if [ "$?" -ne "0" ] || [ ! -d "$PYSMELL_DIR_PATH" ]; then
  die "[ERROR] Clone of 'PySmell' failed!"
fi

pushd . > /dev/null 2>&1
cd "$PYSMELL_DIR_PATH"
  # Switch to lastest commit
  git checkout f5e9673a3d1b97f8376b7f3884ca0bee5545e1fd || die "[ERROR] Commit 'f5e9673a3d1b97f8376b7f3884ca0bee5545e1fd' not found!"
  # Activate virtual environment
  source "$SCRIPT_DIR/env/bin/activate" || die "[ERROR] Failed to activate virtual environment!"
  # Install tool's dependencies
  python setup.py install               || die "[ERROR] Failed to install tool's requirements!"
  # Deactivate virtual environment
  deactivate                            || die "[ERROR] Failed to deactivate virtual environment!"
popd > /dev/null 2>&1

#
# Subjects
#

OREILLY_QC_DIR="$SCRIPT_DIR/oreilly-qc.github.io"

# Remove any previous file and directory
rm -rf "$OREILLY_QC_DIR"

git clone https://github.com/oreilly-qc/oreilly-qc.github.io.git "$OREILLY_QC_DIR"
if [ "$?" -ne "0" ] || [ ! -d "$OREILLY_QC_DIR" ]; then
  die "[ERROR] Clone of 'O'Reilly' programs!"
fi

pushd . > /dev/null 2>&1
cd "$OREILLY_QC_DIR"
  # Switch to lastest commit
  git checkout 54a30ae14ce37e7db3cf6e550c8880fc5a2a2a2e || die "[ERROR] Commit '54a30ae14ce37e7db3cf6e550c8880fc5a2a2a2e' not found!"
popd > /dev/null 2>&1

# Switch to installed version
pyenv local "3.7.8"                        || die "[ERROR] Failed to load Python v3.7.8!"
# Activate virtual environment
source env/bin/activate                    || die "[ERROR] Failed to activate virtual environment!"
# Install Qiskit
pip install qiskit==0.37.0                 || die "[ERROR] Failed to install Qiskit!"
# Install other modules
pip install qiskit-terra==0.21.0           || die "[ERROR] Failed to install Qiskit Terra!"
pip install qiskit-nature==0.4.3           || die "[ERROR] Failed to install Qiskit Nature!"
pip install qiskit-optimization==0.4.0     || die "[ERROR] Failed to install Qiskit Optimization!"
pip install qiskit-machine-learning==0.4.0 || die "[ERROR] Failed to install Qiskit Machine Learning!"
# Deactivate virtual environment
deactivate                                 || die "[ERROR] Failed to deactivate virtual environment!"
# Revert to system Python version
rm ".python-version"                       || die

#
# Get Qiskit's repositories
#
echo ""
echo "Setting up Qiskit's repositories..."

QISKIT_TERRA_DIR="$SCRIPT_DIR/qiskit-terra"
rm -rf "$QISKIT_TERRA_DIR"

git clone https://github.com/Qiskit/qiskit-terra.git "$QISKIT_TERRA_DIR"
if [ "$?" -ne "0" ] || [ ! -d "$QISKIT_TERRA_DIR" ]; then
  die "[ERROR] Clone of qiskit-terra!"
fi

pushd . > /dev/null 2>&1
cd "$QISKIT_TERRA_DIR"
  git checkout 0.21.0 || die "[ERROR] Version '0.21.0' not found!"
popd > /dev/null 2>&1

QISKIT_MACHINE_LEARNING_DIR="$SCRIPT_DIR/qiskit-machine-learning"
rm -rf "$QISKIT_MACHINE_LEARNING_DIR"

git clone https://github.com/Qiskit/qiskit-machine-learning.git "$QISKIT_MACHINE_LEARNING_DIR"
if [ "$?" -ne "0" ] || [ ! -d "$QISKIT_MACHINE_LEARNING_DIR" ]; then
  die "[ERROR] Clone of qiskit-machine-learning!"
fi

pushd . > /dev/null 2>&1
cd "$QISKIT_MACHINE_LEARNING_DIR"
  git checkout 0.4.0 || die "[ERROR] Version '0.4.0' not found!"
popd > /dev/null 2>&1

QISKIT_NATURE_LEARNING_DIR="$SCRIPT_DIR/qiskit-nature"
rm -rf "$QISKIT_NATURE_LEARNING_DIR"

git clone https://github.com/Qiskit/qiskit-nature.git "$QISKIT_NATURE_LEARNING_DIR"
if [ "$?" -ne "0" ] || [ ! -d "$QISKIT_NATURE_LEARNING_DIR" ]; then
  die "[ERROR] Clone of qiskit-nature!"
fi

pushd . > /dev/null 2>&1
cd "$QISKIT_NATURE_LEARNING_DIR"
  git checkout 0.4.3 || die "[ERROR] Version '0.4.3' not found!"
popd > /dev/null 2>&1

#
# Get Cloc
#
echo ""
echo "Setting up Cloc..."

CLOC_VERSION="v1.94"
CLOC_FILE="cloc"
CLOC_URL="https://raw.githubusercontent.com/AlDanial/cloc/$CLOC_VERSION/$CLOC_FILE"

wget -np -nv "$CLOC_URL" -O "$SCRIPT_DIR/$CLOC_FILE"
if [ "$?" -ne "0" ] || [ ! -s "$SCRIPT_DIR/$CLOC_FILE" ]; then
  die "[ERROR] Failed to download $CLOC_URL!"
fi

# Check whether 'cloc' is available
perl "$SCRIPT_DIR/$CLOC_FILE" --version > /dev/null 2>&1 || die "[ERROR] cloc is not executable."

#
# R packages
#

echo ""
echo "Setting up R..."

Rscript "$SCRIPT_DIR/get-libraries.R" || die "[ERROR] Failed to install/load all required R packages!"

echo ""
echo "DONE! All tools have been successfully prepared."

# EOF
