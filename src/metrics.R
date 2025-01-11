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
