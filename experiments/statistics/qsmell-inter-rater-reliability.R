# ------------------------------------------------------------------------------
# This script performances inter-rater reliability Cohen's Kappa.
#
# Usage:
#   Rscript qsmell-inter-rater-reliability.R
#     <input file path, e.g., ../data/peer-evaluation-of-qsmell.csv>
#     <qsmells generated file path, e.g., ../data/generated/qsmell-metrics/data.csv>
#     <output file path, e.g., qsmell-inter-rater-reliability.tex>
# ------------------------------------------------------------------------------

source('../../utils/statistics/utils.R')

library('irr') # install.packages('irr')
library('caret') # install.packages('caret')

# ------------------------------------------------------------------------- Args

args = commandArgs(trailingOnly=TRUE)
if (length(args) != 3) {
  stop('USAGE: Rscript qsmell-inter-rater-reliability.R <input file path, e.g., ../data/peer-evaluation-of-qsmell.csv> <qsmells generated file path, e.g., ../data/generated/qsmell-metrics/data.csv>')
}

# Args
RATERS_DATA_FILE  <- args[1]
QSMELLS_DATA_FILE <- args[2]
OUTPUT_FILE       <- args[3]

# ---------------------------------------------------------- Rater A vs. Rater B

# Load raters' data
raters_data <- load_CSV(RATERS_DATA_FILE) # rater,name,metric,value
# Add custom column
raters_data$'name-metric' <- paste(raters_data$'name', raters_data$'metric', sep='-')
print(raters_data) # debug

# Get data per rater
rater_A <- rep(NA, times=length(unique(raters_data$'name-metric')))
rater_B <- rep(NA, times=length(unique(raters_data$'name-metric')))
# As data might not be sorted, we manually get data per rater
i <- 1
for (name_metric in unique(raters_data$'name-metric')) {
  name_metric_mask <- raters_data$'name-metric' == name_metric
  rater_A[i]       <- raters_data$'value'[name_metric_mask & raters_data$'rater' == 'A']
  rater_B[i]       <- raters_data$'value'[name_metric_mask & raters_data$'rater' == 'B']
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

# ----------------------------------------------------------- QSmell vs. Rater A

# Filter out Rater's A data
raters_data <- raters_data[raters_data$'rater' == 'A', ]
raters_data <- augment_smell_metrics_data(raters_data)
print(raters_data) # debug

# Load QSmell's data
tool_data  <- augment_smell_metrics_data(QSMELLS_DATA_FILE)
# Compute smells' thresholds using all programs' data but the programs that were used by human raters
thresholds <- compute_thresholds(tool_data[tool_data$'name' %!in% unique(raters_data$'name'), ], overall_thresholds=FALSE)
print(thresholds) # debug

# Label programs as smelly, given the computed thresholds
tool_data   <- label_smelly_programs(tool_data, thresholds)
raters_data <- label_smelly_programs(raters_data, thresholds)

# Set and init tex file
unlink(OUTPUT_FILE)
sink(OUTPUT_FILE, append=FALSE, split=TRUE)

# Table's header
cat('\\begin{tabular}{@{\\extracolsep{\\fill}} lrrrr} \\toprule\n', sep='')
cat('Smell & \\# Instances & Precision & Recall & F1', ' \\\\\n', sep='')
cat('\\midrule\n', sep='')

# Table's body
body_df <- data.frame(num_instances=as.numeric(), precision=as.numeric(), recall=as.numeric(), fone=as.numeric())
for (metric in levels(tool_data$'metric')) {

  # Order is important
  reference <- rep(NA, times=5)
  predicted <- rep(NA, times=5)
  i <- 1
  for (name in unique(raters_data$'name')) {
    reference[i] <- raters_data$'smelly'[raters_data$'name' == name & raters_data$'metric' == metric]
    predicted[i] <-   tool_data$'smelly'[tool_data$'name' == name   & tool_data$'metric' == metric]
    i <- i + 1
  }

  reference  <- factor(reference, levels=c(0, 1))
  predicted  <- factor(predicted, levels=c(0, 1))
  # print(reference) # debug
  # print(predicted) # debug

  result <- confusionMatrix(predicted, reference, mode='everything', positive='1')
  # print(result) # debug

  num_instances <- length(reference[reference == 1])
  precision <- result$'byClass'[['Precision']] * 100.0
  recall    <- result$'byClass'[['Recall']] * 100.0
  fone      <- result$'byClass'[['F1']] * 100.0
  body_df[nrow(body_df)+1, ] <- c(num_instances, precision, recall, fone)
  # toString
  precision <- ifelse(is.na(precision), '---', sprintf('%.2f\\%%', round(precision, 2)))
  recall    <- ifelse(is.na(recall), '---', sprintf('%.2f\\%%', round(recall, 2)))
  fone      <- ifelse(is.na(fone), '---', sprintf('%.2f\\%%', round(fone, 2)))

  cat(metric,
      ' & ', num_instances,
      ' & ', precision,
      ' & ', recall,
      ' & ', fone,
      ' \\\\\n', sep='')
}

# Overall median and average
cat('\\midrule\n', sep='')
cat('Median',
    ' & ', sprintf('%.2f', round(median(body_df$'num_instances'), 2)),
    ' & ', sprintf('%.2f\\%%', round(median(body_df$'precision', na.rm=TRUE), 2)),
    ' & ', sprintf('%.2f\\%%', round(median(body_df$'recall', na.rm=TRUE), 2)),
    ' & ', sprintf('%.2f\\%%', round(median(body_df$'fone', na.rm=TRUE), 2)),
    ' \\\\\n', sep='')
cat('Average',
    ' & ', sprintf('%.2f', round(mean(body_df$'num_instances'), 2)),
    ' & ', sprintf('%.2f\\%%', round(mean(body_df$'precision', na.rm=TRUE), 2)),
    ' & ', sprintf('%.2f\\%%', round(mean(body_df$'recall', na.rm=TRUE), 2)),
    ' & ', sprintf('%.2f\\%%', round(mean(body_df$'fone', na.rm=TRUE), 2)),
    ' \\\\\n', sep='')

# Table's footer
cat('\\bottomrule', '\n', sep='')
cat('\\end{tabular}', '\n', sep='')
sink()

# EOF
