# ------------------------------------------------------------------------------
# A set of utility functions.
# ------------------------------------------------------------------------------

# Common external packages
library('data.table') # install.packages('data.table')
library('stringr') # install.packages('stringr')

# --------------------------------------------------------------------- Wrappers

'%!in%' <- function(x,y)!('%in%'(x,y)) # Wrapper to 'not in'

load_CSV <- function(csv_path) {
  return (read.csv(csv_path, header=TRUE, stringsAsFactors=FALSE))
}

load_CSV_GZ <- function(csv_path) {
  return (read.table(gzfile(csv_path), header=TRUE, stringsAsFactors=FALSE))
}

replace_string <- function(string, find, replace) {
  gsub(find, replace, string)
}

# ---------------------------------------------------------------- Study related

GATES_ERROR <- 0.03512

#
# TODO add doc
#
augment_smell_metrics_data <- function(input) {
  # Load subject's data
  subjects          <- load_CSV('../../subjects/data/subjects.csv') # origin,name,path
  locs              <- load_CSV('../../subjects/data/generated/subjects-locs.csv') # origin,name,path,lines_of_code
  matrices          <- load_CSV('../../subjects/data/generated/transpiled-matrices-data.csv') # origin,name,path,num_qubits,num_clbits,num_ops
  subjects          <- merge(subjects, merge(locs, matrices, by=c('origin', 'name', 'path'), all=TRUE), by=c('origin', 'name', 'path'), all=TRUE)
  subjects$'module' <- sapply(subjects$'path', FUN = function(x) unlist(strsplit(x, '/'))[1])

  # Load smells' data
  smell_metrics_data <- input
  if (! is.data.frame(input)) {
    smell_metrics_data <- load_CSV(input)
  }
  if ('LC' %in% smell_metrics_data$'metric') {
    smell_metrics_data$'value'[smell_metrics_data$'metric' == 'LC'] <- (1 - GATES_ERROR)^(smell_metrics_data$'value'[smell_metrics_data$'metric' == 'LC'])
  }
  smell_metrics_data$'value' <- as.numeric(smell_metrics_data$'value')
  # Order set of metrics as defined in the paper
  smell_metrics_data$'metric' <- factor(smell_metrics_data$'metric', levels=c('CG', 'ROC', 'NC', 'LC', 'IM', 'IdQ', 'IQ', 'LPQ'))
  # Merge all data
  df <- merge(subjects, smell_metrics_data, by=c('name'), all.y=TRUE)

  return(df)
}

#
# Convert the origin name of each subject into a pretty string.
#
pretty_print_origin <- function(origin) {
  if (origin == 'qiskit') {
    return('Qiskit')
  } else if (origin == 'oreilly-qc') {
    return("O'Reilly Programming Quantum Computers' book")
  } else {
    return(origin)
  }
}

#
# Compute the set of thresholds per smell
#
compute_thresholds <- function(df, overall_thresholds=FALSE) {
  thresholds <- data.frame(origin=as.character(), metric=as.character(), value=as.numeric())

  for (metric in unique(df$'metric')) {
    if (overall_thresholds == TRUE) {
      threshold_value <- median(df$'value'[df$'metric' == metric])
      for (origin in unique(df$'origin')) {
        thresholds[nrow(thresholds)+1, ] <- c(origin, metric, threshold_value)
      }
    } else {
      for (origin in unique(df$'origin')) {
        threshold_value <- median(df$'value'[df$'metric' == metric & df$'origin' == origin])
        thresholds[nrow(thresholds)+1, ] <- c(origin, metric, threshold_value)
      }
    }
  }

  # Manual set recommended thresholds
  thresholds$'value'[thresholds$'metric' == 'CG']  <- 1
  thresholds$'value'[thresholds$'metric' == 'LC']  <- 0.50
  thresholds$'value'[thresholds$'metric' == 'IM']  <- 1
  thresholds$'value'[thresholds$'metric' == 'NC']  <- 1
  thresholds$'value'[thresholds$'metric' == 'LPQ'] <- 1
  thresholds$'value'[thresholds$'metric' == 'ROC'] <- 1
  # For the following ones we used the median values
  # thresholds$'threshold'[thresholds$'metric' == 'IdQ']
  # thresholds$'threshold'[thresholds$'metric' == 'IQ']

  thresholds$'value' <- as.numeric(thresholds$'value')
  return(thresholds)
}

#
# Annotate each data point on whether it is smelly or not according to the
# thresholds (either global or local)
#
label_smelly_programs <- function(df, thresholds) {
  df$'smelly' <- 0

  for (metric in unique(df$'metric')) {
    metric_mask <- df$'metric' == metric

    for (name in unique(df$'name')) {
      name_mask <- df$'name' == name
      origin    <- unique(df$'origin'[name_mask])
      value     <- df$'value'[metric_mask & name_mask]
      threshold <- thresholds$'value'[thresholds$'origin' == origin & thresholds$'metric' == metric]

      if (value == 0 && threshold == 0) {
        # ignore
      } else if (metric == 'LC' && value <= threshold) {
        df$'smelly'[metric_mask & name_mask] <- 1
      } else if (metric != 'LC' && value >= threshold) {
        df$'smelly'[metric_mask & name_mask] <- 1
      }
    }
  }

  return(df)
}

# EOF
