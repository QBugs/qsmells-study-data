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

# ------------------------------------------------------------------------- Main

# Load QSmell's data
tool_data  <- augment_smell_metrics_data(INPUT_FILE)
# Discard the subjects used in the peer-agreement to evaluated QSmell effectiveness
tool_data <- tool_data[tool_data$'name' %!in% c('qsvc', 'fae'), ] # FIXME automatically get this data from ../data/peer-evaluation-of-qsmell.csv

# Compute smells' thresholds
thresholds <- compute_thresholds(tool_data)
print(thresholds) # debug

# Label programs as smelly, given the computed thresholds
df <- label_smelly_programs(tool_data, thresholds)
# Fix name for latex
df$'name' <- gsub('_', '\\\\_', df$'name')

# Debug
print(df)
print(summary(df))

metrics <- levels(df$'metric')

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
  if (length(unique(df$'origin')) > 1) {
    cat('\\rowcolor{gray!25}\n', sep='')
    cat('\\multicolumn{', length(metrics)+1, '}{c}{\\textbf{\\textit{', pretty_print_origin(origin), '}}} \\\\\n', sep='')
  }

  for (module in sort(unique(df$'module'[origin_mask]))) {
    module_mask <- df$'module' == module

    if (origin == 'oreilly-qc') {
      module <- ''
    } else {
      module <- paste0('(', module, ') ')
    }

    for (name in sort(unique(df$'name'[origin_mask & module_mask]))) {
      name_mask <- df$'name' == name
      cat(module, '', name, sep='')

      for (metric in metrics) {
        metric_mask  <- df$'metric' == metric
        metric_value <- df$'value'[origin_mask & module_mask & name_mask & metric_mask]

        is_smelly    <- df$'smelly'[origin_mask & module_mask & name_mask & metric_mask]
        cellcolor    <- ifelse(is_smelly, '\\cellcolor{gray!25}', '')

        if (metric == 'LC') {
          cat(' & ', cellcolor, sprintf('%.2f', round(metric_value, 2)), sep='')
        } else {
          cat(' & ', cellcolor, metric_value, sep='')
        }
      }
      cat(' \\\\\n', sep='')
    }
  }

  cat('\\midrule\n', sep='')
  body_bottom('Median', metrics, df[origin_mask, ], median)
  body_bottom('Average', metrics, df[origin_mask, ], mean)
  body_bottom('Threshold', metrics, thresholds[thresholds$'origin' == origin, ], mean)
}

if (length(unique(df$'origin')) > 1) {
  cat('\\midrule\n', sep='')
  cat('\\midrule\n', sep='')
  body_bottom('Overall Median', metrics, df, median)
  body_bottom('Overall Average', metrics, df, mean)
}

# Table's footer
cat('\\bottomrule', '\n', sep='')
cat('\\end{tabular}', '\n', sep='')
sink()

# EOF
