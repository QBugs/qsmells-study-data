args = commandArgs(trailingOnly=TRUE)
if (length(args) != 1) {
  stop('USAGE: get-libraries.R <path>')
}

PATH <- args[1]

# Load utils file
source(paste(PATH, '/../utils/statistics/utils.R', sep=''))
# R repository
repository <- 'http://cran.us.r-project.org'
# Install packages
install.packages('data.table', lib=local_library, repos=repository)
install.packages('stringr', lib=local_library, repos=repository)
install.packages('irr', lib=local_library, repos=repository)
install.packages('caret', lib=local_library, repos=repository)
# Load libraries (aka runtime sanity check)
library('data.table', lib.loc=local_library)
library('stringr', lib.loc=local_library)
library('irr', lib.loc=local_library)
library('caret', lib.loc=local_library)
# Exit
quit(save="no", status=0)
# EOF
