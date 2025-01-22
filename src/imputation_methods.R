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
#' @param noise Logical; if TRUE, adds noise to the imputed values (default = FALSE)
#' @return Data frame with missing values imputed using regression
regression_imputation <- function(data, noise = FALSE) {
  for (col in names(data)) {
    if (any(is.na(data[[col]])) && is.numeric(data[[col]])) {
      complete_data <- data[complete.cases(data), ]
      incomplete_rows <- which(is.na(data[[col]]))
      predictors <- setdiff(names(data), col)
      model <- lm(as.formula(paste(col, "~ .")), data = complete_data)
      predictions <- predict(model, newdata = data[incomplete_rows, predictors, drop = FALSE])

      if (noise) {
        # Calculate residuals and their standard deviation
        residuals <- model$residuals
        residual_sd <- sd(residuals, na.rm = TRUE)

        # Add random noise to the predictions (scaled by residual_sd)
        noise_values <- rnorm(length(predictions), mean = 0, sd = residual_sd)
        predictions <- predictions + noise_values
      }

      data[[col]][incomplete_rows] <- predictions
    }
  }
  return(data)
}

# ALTERNATIVE APPROACH TO DISCUSS
#' Regression Imputation with Empirical Noise
#' @param data Data frame with missing values
#' @param noise Logical; if TRUE, adds noise to the imputed values based on residuals (default = FALSE)
#' @return Data frame with missing values imputed using regression
regression_imputation_emp <- function(data, noise = FALSE) {
  for (col in names(data)) {
    if (any(is.na(data[[col]])) && is.numeric(data[[col]])) {
      complete_data <- data[complete.cases(data), ]
      incomplete_rows <- which(is.na(data[[col]]))
      predictors <- setdiff(names(data), col)
      model <- lm(as.formula(paste(col, "~ .")), data = complete_data)
      predictions <- predict(model, newdata = data[incomplete_rows, predictors, drop = FALSE])
      
      if (noise) {
        # Use residuals as a proxy for noise
        residuals <- model$residuals
        
        # Sample noise from the residuals to preserve their empirical distribution
        noise_values <- sample(residuals, size = length(predictions), replace = TRUE)
        
        # Add the sampled noise to the predictions
        predictions <- predictions + noise_values
      }
      
      data[[col]][incomplete_rows] <- predictions
    }
  }
  return(data)
}

#' Custom regression imputation which can work with mice
custom_regression_impute <- function(y, ry, x, noise = FALSE, ...) {
# custom_regression_impute <- function(y, ry, x, noise = TRUE, ...) {
  # Ensure `x` is a data frame
  x <- as.data.frame(x)
  
  # Fit a linear model using observed data
  model <- lm(y ~ ., data = data.frame(y = y[ry], x = x[ry, , drop = FALSE]))
  predictions <- predict(model, newdata = x[!ry, , drop = FALSE])
  
  if (noise) {
    # Use residuals as noise
    residuals <- model$residuals
    noise_values <- sample(residuals, size = length(predictions), replace = TRUE)
    predictions <- predictions + noise_values
  }
  
  return(predictions)
}

#' Hot-deck Imputation
#' @pram data Data frame with missing values
#' @return Data frame with missing values imputed using hot-deck imputation
# Hot-deck Imputation using mice
hot_deck_imputation <- function(data) {
  imputed_data <- mice(data, method = "pmm", m = 1, maxit = 1, printFlag = FALSE)
  complete_data <- complete(imputed_data)
  return(complete_data)
}

#' Expectation-Maximization Imputation
#' @param data Data frame with missing values
#' @return Data frame with missing values imputed using a simple EM-like approach
em_imputation <- function(data) {
  imputed_data <- mice(data, method = "norm", m = 1, maxit = 1, printFlag = FALSE)
  complete_data <- complete(imputed_data)
  return(complete_data)
}

#' Tree-Based Imputation with Optional Noise
#' @param data Data frame with missing values
#' @param noise Logical; if TRUE, adds noise to the imputed values based on residuals (default = FALSE)
#' @return Data frame with missing values imputed using Random Forest
tree_based_imputation <- function(data, noise = FALSE) { 
  # Loop through each column with missing values
  for (col in names(data)) {
    if (any(is.na(data[[col]]))) {
      # Create a model to predict the missing values in the column
      missing_indices <- which(is.na(data[[col]]))
      complete_data <- data[!is.na(data[[col]]), ]
      
      # Fit the Random Forest model
      rf_model <- randomForest(as.formula(paste(col, "~ .")), data = complete_data)
      
      # Predict missing values
      imputed_values <- predict(rf_model, newdata = data[missing_indices, ])
      
      if (noise) {
        # Calculate residuals
        residuals <- complete_data[[col]] - predict(rf_model, newdata = complete_data)
        
        # Sample noise from residuals
        noise_values <- sample(residuals, size = length(imputed_values), replace = TRUE)
        
        # Add noise to imputed values
        imputed_values <- imputed_values + noise_values
      }
      
      # Replace missing values with imputed values
      data[[col]][missing_indices] <- imputed_values
    }
  }
  return(data)
}


#' Generalized Additive Model (GAM) Based Imputation
#' 
#' This function performs imputation of missing numeric values in a data frame using 
#' a Generalized Additive Model (GAM). Users can optionally add noise to the imputed values 
#' to mimic the variability of the original data.
#' 
#' @param data A data frame containing numeric and/or categorical columns with missing values.
#' @param max_predictors The maximum number of predictors to use for the GAM model. Default is 3.
#' @param noise Logical. If TRUE, adds random noise to the predictions based on the residuals' 
#'   standard deviation. Default is TRUE.
#' @return A data frame with missing numeric values imputed using GAM, optionally with added noise.
#' @examples
#' # Example usage:
#' data <- data.frame(a = c(1, 2, NA, 4), b = c(2, NA, 3, 4), c = c(NA, 1, 2, 3))
#' imputed_data <- gam_based_imputation_with_noise(data, max_predictors = 2, noise = TRUE)
#' @export
gam_based_imputation <- function(data,noise = FALSE, max_predictors = 3) {
  # Create a copy of the data
  imputed_data <- data

  # Function to find best predictor columns
  find_predictors <- function(target_col, data, max_predictors) {
    numeric_cols <- names(data)[sapply(data, is.numeric)]
    numeric_cols <- setdiff(numeric_cols, target_col)

    if (length(numeric_cols) == 0) return(character(0))

    # Calculate correlations with target column
    correlations <- sapply(numeric_cols, function(col) {
      abs(cor(data[[target_col]], data[[col]], 
          use = "pairwise.complete.obs"))
    })

    # Sort and select top predictors
    predictors <- names(sort(correlations, decreasing = TRUE))
    predictors[1:min(length(predictors), max_predictors)]
  }

  # Process each column
  for (col in names(imputed_data)) {
    if (any(is.na(imputed_data[[col]])) && is.numeric(imputed_data[[col]])) {
      # Find rows with missing values
      missing_indices <- which(is.na(imputed_data[[col]]))

      # Skip if too few complete cases
      if (sum(!is.na(imputed_data[[col]])) < 10) next

      # Find best predictor columns
      predictors <- find_predictors(col, imputed_data, max_predictors)

      if (length(predictors) > 0) {
        # Create formula for GAM
        formula_terms <- paste("s(", predictors, ")", collapse = " + ")
        formula_str <- paste(col, "~", formula_terms)

        # Prepare training data
        train_data <- imputed_data[!is.na(imputed_data[[col]]), 
          c(col, predictors)]

        # Fit GAM model and predict
        tryCatch({
          gam_model <- gam(as.formula(formula_str), data = train_data)

          # Prepare prediction data
          pred_data <- imputed_data[missing_indices, predictors, drop = FALSE]

          # Make predictions
          predictions <- predict(gam_model, newdata = pred_data)

          if (noise) {
            # Calculate residuals and their standard deviation
            residuals <- residuals(gam_model)
            residual_sd <- sd(residuals, na.rm = TRUE)

            # Add random noise to the predictions (scaled by residual_sd)
            noise_values <- rnorm(length(predictions), mean = 0, sd = residual_sd)
            predictions <- predictions + noise_values
          }

          # Impute missing values
          imputed_data[[col]][missing_indices] <- predictions
        }, error = function(e) {
          warning(paste("Failed to impute", col, ":", e$message))
        })
      }
    }
  }

  return(imputed_data)
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
