# ------------------------------------------------------------------------------
# This script prints out a Latex table with the survey's results per smell
# metric, i.e., whether a user agreed, disagreed, did not know a snippet had a
# smell.
#
# Usage:
#   Rscript results-per-smell-as-table.R
#     <input file path, e.g., ../data/responses.csv>
#     <output file path, e.g., results-per-smell.tex>
# ------------------------------------------------------------------------------

source('../../utils/statistics/utils.R')

# ------------------------------------------------------------------------- Args

args = commandArgs(trailingOnly=TRUE)
if (length(args) != 2) {
  stop('USAGE: Rscript results-per-smell-as-table.R <input file path, e.g., ../data/responses.csv> <output file path, e.g., results-per-smell.tex>')
}

# Args
INPUT_FILE  <- args[1]
OUTPUT_FILE <- args[2]

# ------------------------------------------------------------------------- Main

# Load Survey's data
df <- load_CSV(INPUT_FILE)
# Remove second row which only contains a verbatim copy of the questions
df <- df[-1, ]
# Rename questions' id to smell name to ease plot
colnames(df)[colnames(df) == 'Q7']  <- 'CG'
colnames(df)[colnames(df) == 'Q8']  <- 'ROC'
colnames(df)[colnames(df) == 'Q9']  <- 'NC'
colnames(df)[colnames(df) == 'Q10'] <- 'LC'
colnames(df)[colnames(df) == 'Q11'] <- 'IM'
colnames(df)[colnames(df) == 'Q12'] <- 'IdQ'
colnames(df)[colnames(df) == 'Q13'] <- 'IQ'
colnames(df)[colnames(df) == 'Q14'] <- 'LPQ'

SMELL_METRICS <- c('CG', 'ROC', 'NC', 'LC', 'IM', 'IdQ', 'IQ', 'LPQ')
TOTAL_NUMBER_OF_RESPONSES <- nrow(df)

# Debug
print(df)
print(TOTAL_NUMBER_OF_RESPONSES)
print(summary(df))
print(names(df))

# Set and init tex file
unlink(OUTPUT_FILE)
sink(OUTPUT_FILE, append=FALSE, split=TRUE)

# Header
cat('\\begin{tabular}{@{\\extracolsep{\\fill}} l ', paste0(replicate(length(SMELL_METRICS), 'r'), collapse=''), 'r} \\toprule\n', sep='')
for (metric in SMELL_METRICS) {
  cat(' & ', metric, sep='')
}
cat(' & \\emph{Average} \\\\\n', sep='')
cat('\\midrule\n', sep='')

for(option in c('Yes', 'No', '')) {
  if (option == 'Yes') {
    cat('Agree', sep='')
  } else if (option == 'No') {
    cat('Disagree', sep='')
  } else if (option == '') {
    cat('Do not know', sep='')
  }

  ratios <- c()
  for (metric in SMELL_METRICS) {
    num   <- nrow(df[df[[metric]] == option, ])
    ratio <- (num / TOTAL_NUMBER_OF_RESPONSES) * 100.0
    ratios <- c(ratios, ratio)
    cat(' & ', sprintf('%.2f', round(ratio, 2)), '\\%', sep='')
  }
  cat(' & ', sprintf('%.2f', round(mean(ratios), 2)), '\\% \\\\\n', sep='')
}

# Table's footer
cat('\\bottomrule', '\n', sep='')
cat('\\end{tabular}', '\n', sep='')
sink()

# EOF
