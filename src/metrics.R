#' Calculate Mean Absolute Error
#' @description Computes the Mean Absolute Error (MAE) between the actual and predicted values.
#' @param actual Numeric vector of actual values.
#' @param predicted Numeric vector of predicted values.
#' @return The MAE value (numeric).
#' @examples
#' actual <- c(1, 2, 3)
#' predicted <- c(1, 2, 2)
#' mae(actual, predicted)
mae <- function(actual, predicted) {
  if (length(actual) != length(predicted)) {
    stop("The lengths of actual and predicted vectors must be the same.")
  }
  
  mae <- mean(abs(actual - predicted))
  
  return(mae)
}

#' Calculate Root Mean Square Error
#' @description Computes the Root Mean Square Error (RMSE) between the actual and predicted values.
#' @param actual Numeric vector of actual values.
#' @param predicted Numeric vector of predicted values.
#' @return The RMSE value (numeric).
#' @examples
#' actual <- c(1, 2, 3)
#' predicted <- c(1, 2, 2)
#' rmse(actual, predicted)
rmse <- function(actual, predicted) {
  if (length(actual) != length(predicted)) {
    stop("The lengths of actual and predicted vectors must be the same.")
  }
  
  mse <- mean((actual - predicted)^2)
  rmse <- sqrt(mse)
  
  return(rmse)
}

#' Compare Original Data to Imputed Data
#' @description Compares original data with imputed data by calculating various difference metrics
#' @param original_data Original data frame or numeric vector with missing values
#' @param imputed_data Imputed data frame or numeric vector where missing values have been filled
#' @param metrics Character vector of metrics to calculate. Options: 
#'   "mae" (Mean Absolute Error),
#'   "rmse" (Root Mean Square Error),
#'   "correlation" (Pearson correlation for numeric columns)
#' @return List containing:
#'   - overall_metrics: Averaged metrics across all columns
#' @examples
#' # Create sample data
#' original <- data.frame(a = c(1, NA, 3), b = c(4, 5, NA))
#' imputed <- data.frame(a = c(1, 2, 3), b = c(4, 5, 6))
#' compare_imputed_to_original(original, imputed)
compare_imputed_to_original <- function(original_data, imputed_data, 
                                         metrics = c("mae", "rmse", "correlation")) {
  
  # Input validation: Check if original and imputed data have the same dimensions
  if (!identical(dim(original_data), dim(imputed_data))) {
    warning("Original and imputed data must have the same dimensions. Returning NA for all metrics.")
    return(NA)
  }
  
  # Convert vectors to data frames if necessary
  if (is.vector(original_data)) {
    original_data <- data.frame(x = original_data)
    imputed_data <- data.frame(x = imputed_data)
  }
  
  # Initialize results list for overall metrics
  overall_metrics <- list()
  
  # Calculate metrics for each numeric column
  numeric_cols <- sapply(original_data, is.numeric)
  
  for (col in names(original_data)[numeric_cols]) {
    orig_values <- original_data[[col]]
    imp_values <- imputed_data[[col]]
    
    # Only compare non-NA values in original data
    valid_idx <- !is.na(orig_values)
    
    if (sum(valid_idx) > 0) {
      # Calculate requested metrics
      for (metric in metrics) {
        if (metric == "mae") {
          mae <- mean(abs(orig_values[valid_idx] - imp_values[valid_idx]))
          overall_metrics[[metric]] <- c(overall_metrics[[metric]], mae)
        }
        if (metric == "rmse") {
          rmse <- sqrt(mean((orig_values[valid_idx] - imp_values[valid_idx])^2))
          overall_metrics[[metric]] <- c(overall_metrics[[metric]], rmse)
        }
        if (metric == "correlation") {
          correlation <- cor(orig_values[valid_idx], imp_values[valid_idx], method = "pearson")
          overall_metrics[[metric]] <- c(overall_metrics[[metric]], correlation)
        }
      }
    }
  }
  
  # Return averaged overall metrics
  for (metric in metrics) {
    overall_metrics[[metric]] <- mean(overall_metrics[[metric]], na.rm = TRUE)
  }
  
  return(overall_metrics)
}

#' Calculate 1D Wasserstein Distance
#'
#' @description Computes the one-dimensional Wasserstein distance (also known as the Earth Mover's Distance) 
#' between two numeric vectors.
#'
#' @param original_values Numeric vector of original values.
#' @param imputed_values Numeric vector of imputed (or second) values.
#' @return A single numeric value representing the Wasserstein distance between the two vectors.
#'
#' @details
#' This function uses \code{transport::wasserstein1d}, which implements the 1D Wasserstein distance. 
#' In one dimension, it can be interpreted as the minimum cost of transporting the "mass" of one distribution 
#' into the other.
#'
#' @examples
#' \dontrun{
#' library(transport)
#' set.seed(123)
#' original_vals <- rnorm(100, 5, 2)
#' imputed_vals <- rnorm(100, 5.2, 2)
#' wd <- wasserstein_distance(original_vals, imputed_vals)
#' print(wd)
#' }
#'
#' @export
wasserstein_distance <- function(original_values, imputed_values) {
  if (!is.numeric(original_values) || !is.numeric(imputed_values)) {
    stop("Both 'original_values' and 'imputed_values' must be numeric vectors.")
  }
  
  if (length(original_values) != length(imputed_values)) {
    stop("The lengths of 'original_values' and 'imputed_values' must be the same.")
  }
  
  # Compute and return 1D Wasserstein distance
  distance <- transport::wasserstein1d(original_values, imputed_values)
  return(distance)
}

#' Calculate Jensen–Shannon Divergence Using KDE
#'
#' @description Computes the Jensen–Shannon Divergence (JSD) between two numeric vectors by first estimating 
#' their density distributions via Kernel Density Estimation (KDE).
#'
#' @param original_values Numeric vector of original values.
#' @param imputed_values Numeric vector of imputed (or second) values.
#' @return A single numeric value representing the JSD between the two estimated distributions.
#'
#' @details
#' 1. Uses \code{density()} to estimate the kernel density of each vector over a common range.
#' 2. Normalizes each density to ensure they sum to 1, effectively treating them as discrete probability distributions.
#' 3. Computes the Jensen–Shannon Divergence via \code{philentropy::JSD}.
#'
#' @examples
#' \dontrun{
#' library(philentropy)
#' set.seed(123)
#' original_vals <- rnorm(100, 5, 2)
#' imputed_vals <- rnorm(100, 5.2, 2)
#' js_div <- jsd_distance(original_vals, imputed_vals)
#' print(js_div)
#' }
#'
#' @export
jsd_distance <- function(original_values, imputed_values) {
  if (!is.numeric(original_values) || !is.numeric(imputed_values)) {
    stop("Both 'original_values' and 'imputed_values' must be numeric vectors.")
  }
  
  if (length(original_values) != length(imputed_values)) {
    stop("The lengths of 'original_values' and 'imputed_values' must be the same.")
  }
  
  # Determine a common range for density estimation
  common_range <- range(c(original_values, imputed_values))
  
  # Estimate densities
  original_kde <- density(original_values, from = common_range[1], to = common_range[2], n = 1024)
  imputed_kde  <- density(imputed_values, from = common_range[1], to = common_range[2], n = 1024)
  
  # Normalize densities so they sum to 1
  p <- original_kde$y / sum(original_kde$y)
  q <- imputed_kde$y  / sum(imputed_kde$y)
  
  # Combine into a matrix for philentropy::JSD
  distributions <- rbind(p, q)
  
  # Calculate Jensen–Shannon Divergence
  jsd <- philentropy::JSD(distributions, unit = "log2")
  
  return(jsd)
}

#' Compare Original Data to Imputed Data Using Distribution-based Metrics
#'
#' @description Compares original data with imputed data by calculating various distribution-based metrics, 
#' such as the Wasserstein distance and the Jensen–Shannon Divergence (JSD).
#'
#' @param original_data A numeric vector or a data frame containing the original data.
#' @param imputed_data A numeric vector or a data frame of the same dimensions as \code{original_data}, 
#'   containing imputed (or second) values.
#' @param metrics A character vector of metrics to calculate. Possible values include:
#'   \itemize{
#'     \item \code{"wasserstein"} - 1D Wasserstein distance
#'     \item \code{"jsd"} - Jensen–Shannon Divergence via KDE
#'   }
#'
#' @return A named list containing the average of each requested metric across all numeric columns.
#'
#' @details
#' If the input is a numeric vector, it will be converted to a single-column data frame internally. 
#' Missing or non-numeric columns are skipped. 
#'
#' @examples
#' \dontrun{
#' library(transport)
#' library(philentropy)
#'
#' set.seed(123)
#' # Example with vectors
#' original_vals <- rnorm(100, 5, 2)
#' imputed_vals <- rnorm(100, 5.2, 2)
#' compare_distributions(original_vals, imputed_vals)
#'
#' # Example with data frames
#' df_original <- data.frame(
#'   x = rnorm(100, 5, 2),
#'   y = rnorm(100, 10, 3)
#' )
#' df_imputed <- data.frame(
#'   x = rnorm(100, 5.2, 2),
#'   y = rnorm(100, 9.8, 3)
#' )
#' compare_distributions(df_original, df_imputed, metrics = c("wasserstein", "jsd"))
#' }
#'
#' @export
compare_distributions <- function(original_data, imputed_data, metrics = c("wasserstein", "jsd")) {
  library(transport)
  library(philentropy)
  # Check if dimensions match (for data frames)
  if (is.data.frame(original_data) && is.data.frame(imputed_data)) {
    if (!identical(dim(original_data), dim(imputed_data))) {
      warning("Original and imputed data frames must have the same dimensions. Returning NA for all metrics.")
      return(NA)
    }
  }
  
  # Convert vectors to data frames
  if (is.vector(original_data)) {
    original_data <- data.frame(col1 = original_data)
    imputed_data  <- data.frame(col1 = imputed_data)
  }
  
  # Ensure both are data frames at this point
  if (!is.data.frame(original_data) || !is.data.frame(imputed_data)) {
    stop("Both 'original_data' and 'imputed_data' must be numeric vectors or data frames.")
  }
  
  # Identify numeric columns
  numeric_cols <- sapply(original_data, is.numeric)
  overall_metrics <- list()
  
  # For each numeric column, calculate requested metrics
  for (col in names(original_data)[numeric_cols]) {
    orig_col <- original_data[[col]]
    imp_col  <- imputed_data[[col]]
    
    # Only compare if lengths match
    if (length(orig_col) == length(imp_col)) {
      for (metric in metrics) {
        # Calculate Wasserstein distance
        if (metric == "wasserstein") {
          wd <- transport::wasserstein1d(orig_col, imp_col)
          overall_metrics[[metric]] <- c(overall_metrics[[metric]], wd)
        }
        # Calculate Jensen–Shannon Divergence
        if (metric == "jsd") {

          # Estimate density ranges
          common_range <- range(c(orig_col, imp_col), na.rm = TRUE)

          # Density
          orig_kde <- density(orig_col, from = common_range[1], to = common_range[2], n = 1024)
          imp_kde  <- density(imp_col,  from = common_range[1], to = common_range[2], n = 1024)

          # Normalize
          p <- orig_kde$y / sum(orig_kde$y)
          q <- imp_kde$y  / sum(imp_kde$y)
          distributions <- rbind(p, q)
          # Suppress messages during JSD calculation
          # jsd_val <- philentropy::JSD(distributions, unit = "log2")
          jsd_val <- suppressMessages(philentropy::JSD(distributions, unit = "log2"))
          overall_metrics[[metric]] <- c(overall_metrics[[metric]], jsd_val)
        }
      }
    }
  }
  
  # Compute averages across columns for each metric
  for (metric in metrics) {
    if (!is.null(overall_metrics[[metric]])) {
      overall_metrics[[metric]] <- mean(overall_metrics[[metric]], na.rm = TRUE)
    } else {
      overall_metrics[[metric]] <- NA
    }
  }
  return(overall_metrics)
}
