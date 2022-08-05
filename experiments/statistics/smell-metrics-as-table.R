# ------------------------------------------------------------------------------
# This script prints out a Latex table with smell metrics info per program and
# per smell metric.
#
# Usage:
#   Rscript smell-metrics-as-table.R
#     <input file path, e.g., ../data/generated/qsmell-metrics/data.csv>
#     <output file path, e.g., qsmell-metrics.tex>
# ------------------------------------------------------------------------------

source('../../utils/statistics/utils.R')

# ------------------------------------------------------------------------- Args

args = commandArgs(trailingOnly=TRUE)
if (length(args) != 2) {
  stop('USAGE: Rscript qsmell-metrics-as-table.R <input file path, e.g., ../data/generated/qsmell-metrics/data.csv> <output file path, e.g., qsmell-metrics.tex>')
}

# Args
INPUT_FILE  <- args[1]
OUTPUT_FILE <- args[2]

GATES_ERROR <- 0.03512

# ------------------------------------------------------------------------- Main

# Load subject's data
subjects          <- load_CSV('../../subjects/data/subjects.csv') # origin,name,path
subjects$'module' <- sapply(subjects$'path', FUN = function(x) unlist(strsplit(x, '/'))[1])
# Load smell metrics data
metrics_data      <- load_CSV(INPUT_FILE) # name,metric,value
if ('LC' %in% metrics_data$'metric') {
  metrics_data$'value'[metrics_data$'metric' == 'LC'] <- (1 - 0.03512)^(metrics_data$'value'[metrics_data$'metric' == 'LC'])
}
metrics_data$'value' <- as.numeric(metrics_data$'value')
# Compute set of metrics
metrics           <- sort(unique(metrics_data$'metric')) # FIXME we might want a custom sort to match the order in the paper

df <- merge(subjects, metrics_data, by=c('name'), all=TRUE)
# Fix name for latex
df$'name' <- gsub('_', '\\\\_', df$'name')
df$'name'[df$'origin' != 'oreilly-qc'] <- paste0('(', df$'module'[df$'origin' != 'oreilly-qc'], ') ', df$'name'[df$'origin' != 'oreilly-qc'])
print(df) # debug
print(summary(df)) # debug

# Compute thresholds
thresholds <- data.frame(origin = as.character(), metric = as.character(), value = as.numeric())
for (origin in sort(unique(df$'origin'))) {
  for (metric in metrics) {
    thresholds[nrow(thresholds)+1, ] <- c(origin, metric, median(df$'value'[df$'origin' == origin & df$'metric' == metric]))
  }
}
thresholds$'value' <- as.numeric(thresholds$'value')
print(thresholds) # debug
print(summary(thresholds)) # debug

# Set and init tex file
unlink(OUTPUT_FILE)
sink(OUTPUT_FILE, append=FALSE, split=TRUE)

body_bottom <- function(text, metrics, df, fun=mean) {
  cat('\\textit{', text, '}', sep='')
  for (metric in metrics) {
    metric_mask  <- df$'metric' == metric
    metric_value <- sprintf('%.2f', round(fun(df$'value'[metric_mask]), 2))
    cat(' & ', metric_value, sep='')
  }
  cat(' \\\\\n', sep='')
}

# Header
cat('\\begin{tabular}{@{\\extracolsep{\\fill}} l ', paste0(replicate(length(metrics), 'r'), collapse=''), '} \\toprule\n', sep='')
cat('Name', sep='')
for (metric in metrics) {
  cat(' & ', metric, sep='')
}
cat(' \\\\\n', sep='')

# Body
for (origin in sort(unique(df$'origin'))) {
  origin_mask <- df$'origin' == origin

  cat('\\midrule\n', sep='')
  cat('\\rowcolor{gray!25}\n', sep='')
  cat('\\multicolumn{', length(metrics)+1, '}{c}{\\textbf{\\textit{', pretty_print_origin(origin), '}}} \\\\\n', sep='')

  for (name in sort(unique(df$'name'[origin_mask]))) {
    name_mask <- df$'name' == name
    cat(name, sep='')

    for (metric in metrics) {
      metric_mask  <- df$'metric' == metric
      metric_value <- df$'value'[origin_mask & name_mask & metric_mask]

      # Is value above the threshold?
      threshold_value <- thresholds$'value'[thresholds$'origin' == origin & thresholds$'metric' == metric]
      cellcolor <- ifelse(metric_value == 0 && threshold_value == 0, '',
                     ifelse(metric_value > threshold_value, '\\cellcolor{gray!25}', '')
                   )

      if (metric == 'LC') {
        cat(' & ', cellcolor, sprintf('%.2f', round(metric_value, 2)), sep='')
      } else {
        cat(' & ', cellcolor, metric_value, sep='')
      }
    }
    cat(' \\\\\n', sep='')
  }

  cat('\\midrule\n', sep='')
  body_bottom('Median', metrics, df[origin_mask, ], median)
  body_bottom('Average', metrics, df[origin_mask, ], mean)
}

cat('\\midrule\n', sep='')
cat('\\midrule\n', sep='')
body_bottom('Overall Median', metrics, df, median)
body_bottom('Overall Average', metrics, df, mean)

# Table's footer
cat('\\bottomrule', '\n', sep='')
cat('\\end{tabular}', '\n', sep='')
sink()

# EOF
