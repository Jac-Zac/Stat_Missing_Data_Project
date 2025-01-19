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
          overall_metrics[[metric]] <- c(overall_metrics[[metric]], sqrt(jsd_val))
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
