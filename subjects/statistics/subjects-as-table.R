# ------------------------------------------------------------------------------
# This script prints out a Latex table with info of each software under test
# used in the experiments.
#
# Usage:
#   Rscript subjects-as-table.R
#     <output file path, e.g., subjects.tex>
# ------------------------------------------------------------------------------

source('../../utils/statistics/utils.R')

# ------------------------------------------------------------------------- Args

args = commandArgs(trailingOnly=TRUE)
if (length(args) != 1) {
  stop('USAGE: Rscript subjects-as-table.R <output file path, e.g., subjects.tex>')
}

# Args
OUTPUT_FILE <- args[1]

# ------------------------------------------------------------------------- Main

# Load subject's data
subjects <- load_CSV('../data/subjects.csv') # origin,name,path
locs     <- load_CSV('../data/generated/subjects-locs.csv') # origin,name,path,lines_of_code
matrices <- load_CSV('../data/generated/transpiled-matrices-data.csv') # origin,name,path,num_qubits,num_clbits,num_ops

df <- merge(subjects, merge(locs, matrices, by=c('origin', 'name', 'path'), all=TRUE), by=c('origin', 'name', 'path'), all=TRUE)
df$'module' <- sapply(df$'path', FUN = function(x) unlist(strsplit(x, '/'))[1])
print(df) # debug
print(summary(df)) # debug

# Set and init tex file
unlink(OUTPUT_FILE)
sink(OUTPUT_FILE, append=FALSE, split=TRUE)

# Header
cat('\\begin{tabular}{@{\\extracolsep{\\fill}} l rrrr} \\toprule\n', sep='')
cat('Name & \\# LOC & \\# Qubits & \\# Clbits & \\# Operations \\\\\n', sep='')

# Body
for (origin in sort(unique(df$'origin'))) {
  origin_mask <- df$'origin' == origin

  cat('\\midrule\n', sep='')
  if (length(unique(df$'origin')) > 1) {
    cat('\\rowcolor{gray!25}\n', sep='')
    cat('\\multicolumn{5}{c}{\\textbf{\\textit{', pretty_print_origin(origin), '}}} \\\\\n', sep='')
  }

  for (module in sort(unique(df$'module'[origin_mask]))) {
    module_mask <- df$'module' == module

    if (origin == 'oreilly-qc') {
      module <- ''
    } else {
      module <- paste0('(', module, ') ')
    }

    for (name in sort(df$'name'[origin_mask & module_mask])) {
      name_mask <- df$'name' == name

      locs       <- df$'lines_of_code'[origin_mask & module_mask & name_mask]
      num_qubits <- df$'num_qubits'[origin_mask & module_mask & name_mask]
      num_clbits <- df$'num_clbits'[origin_mask & module_mask & name_mask]
      num_ops    <- df$'num_ops'[origin_mask & module_mask & name_mask]

      cat(module, gsub('_', '\\\\_', name), sep='')
      cat(' & ', locs, sep='')
      cat(' & ', num_qubits, sep='')
      cat(' & ', num_clbits, sep='')
      cat(' & ', num_ops, sep='')
      cat(' \\\\\n', sep='')
    }
  }

  cat('\\midrule\n', sep='')
  cat('\\textit{Median}', sep='')
  cat(' & ', sprintf('%.2f', round(median(df$'lines_of_code'[origin_mask]), 2)), sep='')
  cat(' & ', sprintf('%.2f', round(median(df$'num_qubits'[origin_mask]), 2)), sep='')
  cat(' & ', sprintf('%.2f', round(median(df$'num_clbits'[origin_mask]), 2)), sep='')
  cat(' & ', sprintf('%.2f', round(median(df$'num_ops'[origin_mask]), 2)), sep='')
  cat(' \\\\\n', sep='')
  cat('\\textit{Average}', sep='')
  cat(' & ', sprintf('%.2f', round(mean(df$'lines_of_code'[origin_mask]), 2)), sep='')
  cat(' & ', sprintf('%.2f', round(mean(df$'num_qubits'[origin_mask]), 2)), sep='')
  cat(' & ', sprintf('%.2f', round(mean(df$'num_clbits'[origin_mask]), 2)), sep='')
  cat(' & ', sprintf('%.2f', round(mean(df$'num_ops'[origin_mask]), 2)), sep='')
  cat(' \\\\\n', sep='')
}

# Table's footer
cat('\\bottomrule', '\n', sep='')
cat('\\end{tabular}', '\n', sep='')
sink()

# EOF
