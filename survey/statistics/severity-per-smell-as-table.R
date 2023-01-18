# ------------------------------------------------------------------------------
# This script print out a Latex table with the average and median severity of
# each smell metric.
#
# Usage:
#   Rscript severity-per-smell-as-table.R
#     <input file path, e.g., ../data/responses.csv>
#     <output file path, e.g., severity-per-smell.tex>
# ------------------------------------------------------------------------------

source('../../utils/statistics/utils.R')

# ------------------------------------------------------------------------- Args

args = commandArgs(trailingOnly=TRUE)
if (length(args) != 2) {
  stop('USAGE: Rscript severity-per-smell-as-table.R <input file path, e.g., ../data/responses.csv> <output file path, e.g., severity-per-smell.tex>')
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
colnames(df)[colnames(df) == 'Q16_1'] <- 'CG'
colnames(df)[colnames(df) == 'Q16_2'] <- 'ROC'
colnames(df)[colnames(df) == 'Q16_3'] <- 'NC'
colnames(df)[colnames(df) == 'Q16_4'] <- 'LC'
colnames(df)[colnames(df) == 'Q16_5'] <- 'IM'
colnames(df)[colnames(df) == 'Q16_6'] <- 'IdQ'
colnames(df)[colnames(df) == 'Q16_7'] <- 'IQ'
colnames(df)[colnames(df) == 'Q16_8'] <- 'LPQ'
# Exclude empty data
df <- df[df$'CG' != '', ]
# Convert strings to numbers
df$'CG'  <- as.numeric(as.character(df$'CG'))
df$'ROC' <- as.numeric(as.character(df$'ROC'))
df$'NC'  <- as.numeric(as.character(df$'NC'))
df$'LC'  <- as.numeric(as.character(df$'LC'))
df$'IM'  <- as.numeric(as.character(df$'IM'))
df$'IdQ' <- as.numeric(as.character(df$'IdQ'))
df$'IQ'  <- as.numeric(as.character(df$'IQ'))
df$'LPQ' <- as.numeric(as.character(df$'LPQ'))

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
cat('\\begin{tabular}{@{\\extracolsep{\\fill}} l ', paste0(replicate(length(SMELL_METRICS), 'r'), collapse=''), '} \\toprule\n', sep='')
for (metric in SMELL_METRICS) {
  cat(' & ', metric, sep='')
}
cat(' \\\\\n', sep='')
cat('\\midrule\n', sep='')

cat('\\emph{Average}', sep='')
for (metric in SMELL_METRICS) {
  avg <- mean(df[[metric]])
  cat(' & ', sprintf('%.2f', round(avg, 2)), sep='')
}
cat(' \\\\\n', sep='')

cat('\\emph{Median}', sep='')
for (metric in SMELL_METRICS) {
  med <- median(df[[metric]])
  cat(' & ', sprintf('%.2f', round(med, 2)), sep='')
}
cat(' \\\\\n', sep='')

# Table's footer
cat('\\bottomrule', '\n', sep='')
cat('\\end{tabular}', '\n', sep='')
sink()

# EOF
