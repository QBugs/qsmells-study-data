# ------------------------------------------------------------------------------
# This script computes the inter-rater reliability Cohen's Kappa of Rater A vs.
# Rater B.
#
# Usage:
#   Rscript rater-a-vs-rater-b-inter-rater-reliability.R
#     <input file path, e.g., ../data/peer-evaluation-of-qsmell-v0.csv>
# ------------------------------------------------------------------------------

source('../../utils/statistics/utils.R')

library('irr') # install.packages('irr')

# ------------------------------------------------------------------------- Args

args = commandArgs(trailingOnly=TRUE)
if (length(args) != 1) {
  stop('USAGE: Rscript rater-a-vs-rater-b-inter-rater-reliability.R <input file path, e.g., ../data/peer-evaluation-of-qsmell-v0.csv>')
}

# Args
RATERS_INPUT_FILE <- args[1]

# ------------------------------------------------------------------------- Init

# Load rater's data
raters_df <- load_CSV(RATERS_INPUT_FILE) # rater,name,metric,value
# Add custom column
raters_df$'name-metric' <- paste(raters_df$'name', raters_df$'metric', sep='-')
print(raters_df) # debug

# Get data per rater
rater_A <- rep(NA, times=length(unique(raters_df$'name-metric')))
rater_B <- rep(NA, times=length(unique(raters_df$'name-metric')))
# As data might not be sorted, we manually get data per rater
i <- 1
for (name_metric in unique(raters_df$'name-metric')) {
  name_metric_mask <- raters_df$'name-metric' == name_metric
  rater_A[i]       <- raters_df$'value'[name_metric_mask & raters_df$'rater' == 'A']
  rater_B[i]       <- raters_df$'value'[name_metric_mask & raters_df$'rater' == 'B']
  i <- i + 1
}

rates <- cbind(rater_A, rater_B)
print(rates) # debug

# Measure simple agreement.  By setting tolerance to 0, we have forced the `agree`
# function to require both columns to have the exact same value for it to be
# considered agreement.
agree(rates, tolerance=0)

# Compute Cohen's kappa
kappa2(rates)

# EOF
