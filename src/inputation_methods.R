#' List-wise or Case Deletion
#' @param data Data frame with missing values
#' @return Data frame with rows containing missing values removed
listwise_deletion <- function(data) {
  return(na.omit(data))
}

#' Pairwise Deletion
#' @param data Data frame with missing values
#' @return Data frame with rows selectively removed for pairwise completeness
pairwise_deletion <- function(data) {
  numeric_cols <- sapply(data, is.numeric)
  data <- data[, numeric_cols]

  complete_indices <- which(complete.cases(data))
  data_complete <- data[complete_indices, , drop = FALSE]

  return(data_complete)
}

#' Simple Imputation
#' @param data Data frame with missing values
#' @param method Method for imputation ("mean", "median", etc.)
#' @return Data frame with missing values replaced
simple_imputation <- function(data, method = "mean") {
  for (col in names(data)) {
    if (is.numeric(data[[col]])) {
      if (method == "mean") {
        data[[col]][is.na(data[[col]])] <- mean(data[[col]], na.rm = TRUE)
      } else if (method == "median") {
        data[[col]][is.na(data[[col]])] <- median(data[[col]], na.rm = TRUE)
      }
      # Additional methods can be added here as needed
    }
  }
  return(data)
}

#' Regression Imputation
#' @param data Data frame with missing values
#' @return Data frame with missing values imputed using regression
regression_imputation <- function(data) {
  for (col in names(data)) {
    if (any(is.na(data[[col]])) && is.numeric(data[[col]])) {
      complete_data <- data[complete.cases(data), ]
      incomplete_rows <- which(is.na(data[[col]]))
      predictors <- setdiff(names(data), col)
      model <- lm(as.formula(paste(col, "~ .")), data = complete_data)
      predictions <- predict(model, newdata = data[incomplete_rows, predictors, drop = FALSE])
      data[[col]][incomplete_rows] <- predictions
    }
  }
  return(data)
}

#' Hot-deck Imputation
#' @param data Data frame with missing values
#' @return Data frame with missing values imputed using hot-deck imputation
hot_deck_imputation <- function(data) {
  for (col in names(data)) {
    if (any(is.na(data[[col]]))) {
      non_missing_values <- data[[col]][!is.na(data[[col]])]
      data[[col]][is.na(data[[col]])] <- sample(non_missing_values, sum(is.na(data[[col]])), replace = TRUE)
    }
  }
  return(data)
}

#' Expectation-Maximization Imputation
#' @param data Data frame with missing values
#' @return Data frame with missing values imputed using a simple EM-like approach
em_imputation <- function(data) {
  tol <- 1e-6
  max_iter <- 100
  iter <- 0
  prev_data <- data
  while (iter < max_iter) {
    iter <- iter + 1
    for (col in names(data)) {
      if (is.numeric(data[[col]]) && any(is.na(data[[col]]))) {
        data[[col]][is.na(data[[col]])] <- mean(data[[col]], na.rm = TRUE)
      }
    }
    if (max(abs(as.matrix(data) - as.matrix(prev_data)), na.rm = TRUE) < tol) {
      break
    }
    prev_data <- data
  }
  return(data)
}

#' Multiple Imputation
#' @param data Data frame with missing values
#' @param m Number of imputations to generate
#' @return List of imputed data frames
multiple_imputation <- function(data, m = 5) {
  imputations <- vector("list", m)
  
  for (i in seq_len(m)) {
    imputed_data <- data
    for (col in names(imputed_data)) {
      if (any(is.na(imputed_data[[col]])) && is.numeric(imputed_data[[col]])) {
        missing_indices <- which(is.na(imputed_data[[col]]))
        
        # Simple predictive method for imputation
        observed_values <- imputed_data[[col]][!is.na(imputed_data[[col]])]
        imputed_values <- observed_values + rnorm(length(missing_indices), 0, sd(observed_values, na.rm = TRUE))
        
        imputed_data[[col]][missing_indices] <- imputed_values
      }
    }
    imputations[[i]] <- imputed_data
  }
  
  return(imputations)
}

#' Tree-Based Imputation
#' @param data Data frame with missing values
#' @return Data frame with missing values imputed using Random Forest
tree_based_imputation <- function(data) {
  library(randomForest)
  
  # Loop through each column with missing values
  for (col in names(data)) {
    if (any(is.na(data[[col]]))) {
      # Create a model to predict the missing values in the column
      missing_indices <- which(is.na(data[[col]]))
      complete_data <- data[!is.na(data[[col]]), ]
      
      # Random Forest model: Use other columns to predict the missing column
      rf_model <- randomForest(as.formula(paste(col, "~ .")), data = complete_data)
      
      # Impute the missing values using the Random Forest model
      imputed_values <- predict(rf_model, newdata = data[missing_indices, ])
      data[[col]][missing_indices] <- imputed_values
    }
  }
  return(data)
}

gam_based_imputation <- function(data) {
  library(mgcv)  # For gam function
  
  # Create a row_number column if it doesn't exist
  if (!"row_number" %in% names(data)) {
    data$row_number <- 1:nrow(data)
  }
  
  # Loop through each column with missing values
  for (col in names(data)) {
    if (any(is.na(data[[col]]))) {
      # Only apply GAM imputation to numeric columns
      if (is.numeric(data[[col]])) {
        # Get the rows with no missing values for fitting the model
        complete_data <- data[!is.na(data[[col]]), ]
        
        # Fit a GAM model to predict the missing values
        gam_model <- gam(as.formula(paste(col, "~ s(row_number)")), data = complete_data)
        
        # Predict the missing values using the fitted GAM model
        missing_indices <- which(is.na(data[[col]]))
        
        # Ensure to predict for missing rows only
        if (length(missing_indices) > 0) {
          missing_rows <- data[missing_indices, ]
          missing_rows$row_number <- data$row_number[missing_indices]  # Include row_number in the prediction
          predicted_values <- predict(gam_model, newdata = missing_rows)
          
          # Impute the missing values
          data[[col]][missing_indices] <- predicted_values
        }
      }
    }
  }
  
  # Remove row_number if you don't want it in the final imputed dataset
  data$row_number <- NULL
  
  # Return the data with imputed values
  return(data)
}

# Example usage
# listwise_result <- listwise_deletion(data_with_na)
# pairwise_result <- pairwise_deletion(data_with_na)
# simple_result <- simple_imputation(data_with_na, method = "mean")
# regression_result <- regression_imputation(data_with_na)
# hotdeck_result <- hot_deck_imputation(data_with_na)
# em_result <- em_imputation(data_with_na)
# tree_result <- tree_based_imputation(data_with_na)
# gam_result <- gam_based_imputation(data_with_na)
# multiple_result <- multiple_imputation(data_with_na)
