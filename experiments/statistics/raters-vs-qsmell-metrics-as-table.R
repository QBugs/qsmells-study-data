# ------------------------------------------------------------------------------
# This script prints out a Latex table with Rater A/B vs. QSmell data.
#
# Usage:
#   Rscript raters-vs-qsmell-metrics-as-table.R
#     <input file path, e.g., ../data/peer-evaluation-of-qsmell-v1.csv>
#     <input file path, e.g., ../data/generated/qsmell-metrics/data.csv>
#     <output file path, e.g., raters-vs-qsmell-metrics.tex>
# ------------------------------------------------------------------------------

source('../../utils/statistics/utils.R')

# ------------------------------------------------------------------------- Args

args = commandArgs(trailingOnly=TRUE)
if (length(args) != 3) {
  stop('USAGE: Rscript raters-vs-qsmell-metrics-as-table.R <input file path, e.g., ../data/peer-evaluation-of-qsmell-v1.csv> <input file path, e.g., ../data/generated/qsmell-metrics/data.csv> <output file path, e.g., raters-vs-qsmell-metrics.tex>')
}

# Args
RATERS_INPUT_FILE <- args[1]
QSMELL_INPUT_FILE <- args[2]
OUTPUT_FILE       <- args[3]

SMELL_METRICS <- c('CG', 'ROC', 'NC', 'LC', 'IM', 'IdQ', 'IQ', 'LPQ')

# ------------------------------------------------------------------------- Init

# Load subject's data
subjects <- load_CSV('../../subjects/data/subjects.csv') # origin,name,path

# Load qsmell's data
qsmell_df <- load_CSV(QSMELL_INPUT_FILE) # name,runtime,metric,value
# Get module name
qsmell_df <- merge(subjects, qsmell_df, by=c('name'), all.y=TRUE)
qsmell_df$'module' <- sapply(qsmell_df$'path', FUN = function(x) unlist(strsplit(x, '/'))[1])
# Compute LC
qsmell_df$'value'[qsmell_df$'metric' == 'LC'] <- (1 - GATES_ERROR)^(qsmell_df$'value'[qsmell_df$'metric' == 'LC'])
print(qsmell_df) # debug

# Compute thresholds
thresholds <- compute_thresholds(qsmell_df)
print(thresholds) # debug

# Annotate each data point on whether it is smelly or not
qsmell_df <- label_smelly_programs(qsmell_df, thresholds)

# Load rater's data
raters_df <- load_CSV(RATERS_INPUT_FILE) # rater,name,metric,value
raters_df <- raters_df[raters_df$'rater' == head(raters_df$'rater', n=1), ] # As raters agreed on all programs, we just need one
# Get module name
raters_df <- merge(subjects, raters_df, by=c('name'), all.y=TRUE)
raters_df$'module' <- sapply(raters_df$'path', FUN = function(x) unlist(strsplit(x, '/'))[1])
# Compute LC
raters_df$'value'[raters_df$'metric' == 'LC'] <- (1 - GATES_ERROR)^(raters_df$'value'[raters_df$'metric' == 'LC'])
print(raters_df) # debug
# Annotate each data point on whether it is smelly or not
raters_df <- label_smelly_programs(raters_df, thresholds)
print(raters_df) # debug

# Filter out subjects not used by the raters
qsmell_df <- qsmell_df[qsmell_df$'name' %in% unique(raters_df$'name'), ]

# Set and init tex file
unlink(OUTPUT_FILE)
sink(OUTPUT_FILE, append=FALSE, split=TRUE)

# Header
cat('\\begin{tabular}{@{\\extracolsep{\\fill}} l ', paste0(replicate(length(SMELL_METRICS), 'r'), collapse=''), '} \\toprule\n', sep='')
cat('Name', sep='')
for (metric in SMELL_METRICS) {
  cat(' & ', metric, sep='')
}
cat(' \\\\\n', sep='')

# Raters
cat('\\midrule\n', sep='')
cat('\\multicolumn{', length(SMELL_METRICS)+1, '}{c}{\\textbf{\\textit{Metric values assigned by human raters}}}', ' \\\\\n', sep='')
for (module in sort(unique(raters_df$'module'))) {
  name <- unique(raters_df$'name'[raters_df$'module' == module])

  cat('(', module, ') ', name, sep='')
  for (metric in SMELL_METRICS) {
    value    <- raters_df$'value'[raters_df$'module' == module & raters_df$'metric' == metric]
    isSmelly <- raters_df$'smelly'[raters_df$'module' == module & raters_df$'metric' == metric] == 1
    cat(' & ',
      ifelse(isSmelly, '\\cellcolor{gray!25}', ''),
      ifelse(metric == 'LC', sprintf('%.2f', round(value, 2)), sprintf('%.0f', round(value, 0))), sep='')
  }

  cat(' \\\\\n', sep='')
}

# QSmell
cat('\\midrule\n', sep='')
cat('\\multicolumn{', length(SMELL_METRICS)+1, '}{c}{\\textbf{\\textit{Metric values assigned by QSmell}}}', ' \\\\\n', sep='')
for (module in sort(unique(qsmell_df$'module'))) {
  name <- unique(qsmell_df$'name'[qsmell_df$'module' == module])

  cat('(', module, ') ', name, sep='')
  for (metric in SMELL_METRICS) {
    value    <- qsmell_df$'value'[qsmell_df$'module' == module & qsmell_df$'metric' == metric]
    isSmelly <- qsmell_df$'smelly'[qsmell_df$'module' == module & qsmell_df$'metric' == metric] == 1
    doRatersDisagree <- raters_df$'value'[raters_df$'module' == module & raters_df$'metric' == metric] != value
    cat(' & ',
      ifelse(isSmelly, '\\cellcolor{gray!25}', ''),
      ifelse(metric == 'LC', sprintf(ifelse(doRatersDisagree, '\\textbf{%.2f}', '%.2f'), round(value, 2)), sprintf(ifelse(doRatersDisagree, '\\textbf{%.0f}', '%.0f'), round(value, 0))), sep='')
  }

  cat(' \\\\\n', sep='')
}

# Table's footer
cat('\\bottomrule', '\n', sep='')
cat('\\end{tabular}', '\n', sep='')
sink()

# EOF
