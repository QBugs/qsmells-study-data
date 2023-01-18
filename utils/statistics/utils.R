# ------------------------------------------------------------------------------
# A set of utility functions.
# ------------------------------------------------------------------------------

# Common external packages
library('data.table') # install.packages('data.table')
library('stringr') # install.packages('stringr')
library('ggplot2') # install.packages('ggplot2')

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

embed_fonts_in_a_pdf <- function(pdf_path) {
  library('extrafont') # install.packages('extrafont')
  embed_fonts(pdf_path, options='-dSubsetFonts=true -dEmbedAllFonts=true -dCompatibilityLevel=1.4 -dPDFSETTINGS=/prepress -dMaxSubsetPct=100')
}

# ------------------------------------------------------------------------- Plot

#
# Plots the provided text on a dedicated page.  This function is usually used to
# separate plots for multiple analyses in the same PDF.
#
plot_label <- function(text) {
  library('ggplot2') # install.packages('ggplot2')
  p <- ggplot() + annotate('text', label=text, x=4, y=25, size=8) + theme_void()
  print(p)
}

# ------------------------------------------------------------------------ Stats

#
# Computes the Vargha-Delaney A measure for two populations a and b.
#
# a: a vector of real numbers
# b: a vector of real numbers
# Returns: A real number between 0 and 1
#
A12 <- function(a, b) {
  if (length(a) == 0 && length(b) == 0) {
    return(0.5)
  } else if (length(a) == 0) {
    # motivation is that we have no data for "a" but we do for "b".
    # maybe the process generating "a" always fail (e.g. out of memory)
    return(0)
  } else if (length(b) == 0) {
    return(1)
  }

  # Compute the rank sum (Eqn 13)
  r = rank(c(a,b))
  r1 = sum(r[seq_along(a)])

  # Compute the measure (Eqn 14)
  m = length(a)
  n = length(b)
  #A = (r1/m - (m+1)/2)/n
  A = (2 * r1 - m * (m + 1)) / (2 * m * n) # to avoid float error precision

  return(A)
}

#
# Return true if statistical significant according to wilcox.test, false otherwise.
#
# Wilcoxon–Mann–Whitney test, a nonparametric test of the null hypothesis that,
# for randomly selected values X and Y from two populations, the probability of
# X being greater than Y is equal to the probability of Y being greater than X.
#
wilcox_test <- function(a, b) {
  w = wilcox.test(a, b, exact=FALSE, paired=FALSE)
  pv = w$p.value
  if (!is.nan(pv) && pv < 0.05) {
    return(TRUE)
  }

  return(FALSE)
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
