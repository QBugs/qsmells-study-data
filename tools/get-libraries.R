# R repository
repository="http://cran.us.r-project.org"
# Install packages
install.packages('data.table', repos=repository)
install.packages('stringr', repos=repository)
install.packages('irr', repos=repository)
install.packages('caret', repos=repository)
# Load libraries (aka runtime sanity check)
library('data.table')
library('stringr')
library('irr')
library('caret')
# Exit
quit(save="no", status=0)
# EOF
