args = commandArgs(trailingOnly=TRUE)
if (length(args) != 1) {
  stop('USAGE: get-libraries.R <path>')
}

PATH <- args[1]

# Load utils file
source(paste(PATH, '/../utils/statistics/utils.R', sep=''))
# R repository
repository <- 'https://cloud.r-project.org'
# Install packages
install.packages('data.table', lib=local_library, repos=repository)
install.packages('stringr', lib=local_library, repos=repository)
install.packages('lpSolve', lib=local_library, repos=repository) # required by irr
install.packages('irr', lib=local_library, repos=repository)
install.packages('ggplot2', lib=local_library, repos=repository) # required by caret
install.packages('caret', lib=local_library, repos=repository)
# Load libraries (aka runtime sanity check)
library('data.table', lib.loc=local_library)
library('stringr', lib.loc=local_library)
library('lpSolve', lib.loc=local_library)
library('irr', lib.loc=local_library)
library('ggplot2', lib.loc=local_library)
library('caret', lib.loc=local_library)
# Exit
quit(save='no', status=0)
# EOF
