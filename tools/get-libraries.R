args = commandArgs(trailingOnly=TRUE)
if (length(args) != 1) {
  stop('USAGE: get-libraries.R <path>')
}

PATH <- args[1]

# Load utils file
source(paste(PATH, '/../utils/statistics/utils.R', sep=''))
# R repository
repository <- 'https://cloud.r-project.org'

# Install and load packages (aka runtime sanity check)
install.packages('data.table', lib=local_library, repos=repository)
library('data.table', lib.loc=local_library)
install.packages('stringr', lib=local_library, repos=repository)
library('stringr', lib.loc=local_library)
install.packages('lpSolve', lib=local_library, repos=repository) # required by irr
library('lpSolve', lib.loc=local_library)
install.packages('irr', lib=local_library, repos=repository)
library('irr', lib.loc=local_library)
install.packages('withr', lib=local_library, repos=repository) # required by ggplot2
library('withr', lib.loc=local_library)
install.packages('ggplot2', lib=local_library, repos=repository) # required by caret
library('ggplot2', lib.loc=local_library)
install.packages('e1071', lib=local_library, repos=repository) # required by caret
library('e1071', lib.loc=local_library)
install.packages('caret', lib=local_library, repos=repository)
library('caret', lib.loc=local_library)

# Exit
quit(save='no', status=0)

# EOF
