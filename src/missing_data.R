#' Utility functions for introducing missing data into datasets

#' Introduce Missing Completely At Random (MCAR) values
#' @param data Data frame to introduce missing values into
#' @param prop_missing Overall proportion of missing values to introduce (default: 0.1)
#' @param missing_cols Vector of column names or indices to include missingness into (default: all columns)
#' @return Data frame with MCAR missing values
introduce_mcar <- function(data, prop_missing = 0.1, missing_cols = names(data)) {
  # Ensure the columns are valid
  missing_cols <- intersect(names(data), missing_cols)
  
  # Calculate total number of values in selected columns
  total_values <- nrow(data) * length(missing_cols)

  n_missing <- round(total_values * prop_missing)
  
  if (n_missing == 0) {
    warning("Proportion of missing values is too small to introduce any missingness.")
    return(data)
  }
  
  # Create indices for missingness
  missing_indices <- sample(total_values, n_missing, replace = FALSE)
  
  # Introduce missingness
  for (idx in missing_indices) {
    row <- ((idx - 1) %% nrow(data)) + 1
    col_index <- ((idx - 1) %/% nrow(data)) + 1
    col <- missing_cols[col_index]
    data[row, col] <- NA
  }
  
  return(data)
}

#' Introduce Missing At Random (MAR) values
#' 
#' @param data Data frame to introduce missing values into
#' @param prop_missing Overall proportion of missing values to introduce (default: 0.1)
#' @param predictor_cols Columns used to determine missingness (must be specified)
#' @param target_cols Columns to introduce missing values into (must be specified)
#' @return Data frame with MAR missing values
g_fun <- function(p) {
  # Vector of weights for each decile
  weights <- c(0.5, 0.4, 0.4, 0.4, 0.4, 0.4, 0.3, 0.2, 0.2, 0.1)
  
  # Determine the decile index from 1 to 10
  decile_index <- floor(p * 10) + 1
  
  # Return the weight associated with that decile
  weights[decile_index]
}

introduce_mar <- function(data, 
                          prop_missing = 0.1, 
                          predictor_cols, 
                          target_cols, 
                          method = "percentile", 
                          g = function(p) p) {
  # Check inputs
  if (missing(predictor_cols) || missing(target_cols)) {
    stop("You must specify both predictor_cols and target_cols.")
  }
  if (!all(predictor_cols %in% names(data))) {
    stop("Some predictor_cols are not present in the data.")
  }
  if (!all(target_cols %in% names(data))) {
    stop("Some target_cols are not present in the data.")
  }
  
  # Calculate the total number of values to set as missing
  total_values <- nrow(data) * length(target_cols)
  n_missing <- ceiling(total_values * prop_missing)
  
  if (method == "percentile") {
    # Create a single score from the predictor columns (e.g., sum or average).
    # If there is only one predictor column, you could use that directly.
    predictors <- data[, predictor_cols, drop = FALSE]
    combined_score <- rowSums(predictors, na.rm = TRUE)
    
    # Compute the empirical distribution function (ECDF)
    ecdf_fun <- ecdf(combined_score)
    
    # Convert each row's score to a percentile in [0,1]
    percentiles <- ecdf_fun(combined_score)
    
    # Apply the user-defined function g() to the percentiles
    # g should return non-negative values (acting like "weights")
    g_values <- g(percentiles)
    
    # Normalize these values to use them as probabilities in 'sample()'
    sum_g_values <- sum(g_values, na.rm = TRUE)
    if (sum_g_values == 0) {
      stop("The sum of g(percentiles) is zero. Please check the definition of g().")
    }
    missing_probs <- g_values / sum_g_values
    
    # Introduce missing values for each target column
    for (target_col in target_cols) {
      target_indices <- sample(
        seq_len(nrow(data)), 
        size = n_missing, 
        prob = missing_probs, 
        replace = FALSE
      )
      data[target_indices, target_col] <- NA
    }
    
  }else {
    # Create missingness probabilities based on predictor columns using rank
    predictors <- data[, predictor_cols, drop = FALSE]
    ranks <- apply(predictors, 1, function(row) {
      sum(rank(as.numeric(row), na.last = "keep"), na.rm = TRUE)
    })
    
    # Normalize ranks to create probabilities
    missing_probs <- ranks / sum(ranks, na.rm = TRUE)
    
    # Introduce missing values
    for (target_col in target_cols) {
      target_indices <- sample(
        seq_len(nrow(data)), 
        size = n_missing, 
        prob = missing_probs, 
        replace = FALSE
      )
      data[target_indices, target_col] <- NA
    }
  }
  
  return(data)
}

#' Summarize missing data patterns
#' @param data Data frame to analyze
#' @return List containing missing data summary statistics
summarize_missing <- function(data) {
    total_cells <- prod(dim(data))
    missing_cells <- sum(is.na(data))
    overall_prop <- missing_cells / total_cells
    
    col_missing <- colSums(is.na(data))
    col_prop <- col_missing / nrow(data)
    row_missing <- rowSums(is.na(data))
    row_prop <- row_missing / ncol(data)
    
    summary <- list(
        overall_proportion = overall_prop,
        total_missing = missing_cells,
#        column_proportions = col_prop,
#        row_proportions = row_prop,
        complete_cases = sum(complete.cases(data)),
        incomplete_cases = sum(!complete.cases(data))
    )
    
    return(summary)
}

# Example usage
# data <- data.frame(
#   A = rnorm(100),
#   B = runif(100),
#   C = rbinom(100, 1, 0.5),
#   D = sample(letters[1:5], 100, replace = TRUE)
# )
#
# # Introduce different types of missing values
# data_mcar <- introduce_mcar(data, prop_missing = 0.1)
# data_mar <- introduce_mar(data, prop_missing = 0.1, predictor_cols = c("A", "B"), target_cols = c("C", "D"))
#
# # Analyze missing patterns
# missing_summary <- summarize_missing(data_mar)
# print(missing_summary)
