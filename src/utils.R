#' Print the Code of a Function with Syntax Highlighting
#'
#' This function takes a function object as input and prints its code
#' in a format suitable for inclusion in an R Markdown document.
#' The output includes syntax highlighting when rendered.
#'
#' @param fun A function object whose code needs to be printed.
#' @return Prints the function code as a fenced R code block, ready for use in Markdown.
#' @examples
#' # Define a simple function
#' my_function <- function(x) {
#'   x^2
#' }
#'
#' # Print the function's code
#' print_function_code(my_function)
print_function_code <- function(fun) {
  # Get the function name as a string
  fun_name <- deparse(substitute(fun))
  # Deparse the function code
  fun_code <- deparse(fun)
  # Replace the first line with the function name prepended to `function(...)`
  fun_code[1] <- paste(fun_name, fun_code[1], sep = " <- ")
  # Print raw Markdown for fenced code blocks
  cat("```r\n", paste(fun_code, collapse = "\n"), "\n```", sep = "")
}

#' Evaluate Model Performance on Imputed Data
#'
#' This function evaluates the performance of a linear regression model
#' by training on imputed data and testing on the original test data,
#' calculating both the RMSE and MAE of predictions.
#'
#' @param imputed_data A data frame containing the imputed dataset for training
#' @param test_data A data frame containing the original test dataset
#' @return A named list containing the RMSE and MAE of the model predictions
#' @examples
#' metrics <- evaluate_model_performance(imputed_data, test_data)
#' print(metrics$rmse)
#' print(metrics$mae)
evaluate_model_performance <- function(imputed_data, test_data) {
  # Build linear regression model on imputed data
  model <- lm(target ~ ., data = imputed_data)
  
  # Make predictions on test data
  predictions <- predict(model, test_data)
  
  # Calculate RMSE
  rmse_value <- rmse(test_data$target, predictions)
  
  # Calculate MAE
  mae_value <- mae(test_data$target, predictions)
  
  # Return both RMSE and MAE as a named list
  return(list(rmse = rmse_value, mae = mae_value))
}

#' Impute Data and Generate Predictions
#'
#' This function performs multiple imputation on a dataset, creates models 
#' for each imputed dataset, and generates averaged predictions. It also saves 
#' the final predictions to a file named after the specified method.
#'
#' @param imputation_method A string specifying the imputation method to use
#' @param dataset The original dataset to be imputed
#' @param formula A formula specifying the model structure
#' @param test_data The test dataset for making predictions
#' @param method_label A label to identify the imputation method
#' @return A vector of final predictions averaged across imputed datasets
impute_and_predict <- function(imputation_method, dataset, formula, test_data, method_label) {
  # Impute the dataset using the specified method
  imputed_obj <- mice(dataset, method = imputation_method, m = 5)
  
  # Extract imputed datasets
  imputed_datasets <- complete(imputed_obj, "all")
  
  # Generate predictions for each imputed dataset
  predictions <- lapply(imputed_datasets, function(data) {
    model <- lm(formula, data = data)
    predict(model, newdata = test_data)
  })
  
  # Combine predictions (average across imputations)
  final_predictions <- Reduce("+", predictions) / length(predictions)
  
  return(final_predictions)
}

#' Extract Coefficients and Confidence Intervals
#'
#' This utility function extracts coefficients and their corresponding 
#' confidence intervals from a list of linear models. It allows for 
#' filtering of specific coefficients based on provided names.
#'
#' @param models A list of linear model objects (e.g., created with lm()) 
#'               from which coefficients will be extracted.
#' @param coef_names An optional vector of coefficient names to filter the 
#'                   results. If NULL, all coefficients will be returned.
#' @return A data frame containing the model name, coefficient term, 
#'         estimated value, and lower and upper confidence intervals for each 
#'         coefficient extracted from the models.
#'
#' @examples
#' # Assuming 'models_list' is a list of fitted lm() models:
#' results <- extract_coefficients(models_list)
#'
#' # To extract only specific coefficients:
#' specific_results <- extract_coefficients(models_list, coef_names = c("Intercept", "Age"))
extract_coefficients <- function(models, coef_names = NULL) {
  do.call(rbind, lapply(names(models), function(model_name) {
    coefs <- summary(models[[model_name]])$coefficients
    ci <- confint(models[[model_name]])
    
    # If specific coefficients are provided, filter them
    if (!is.null(coef_names)) {
      coefs <- coefs[coef_names, , drop = FALSE]
      ci <- ci[coef_names, , drop = FALSE]
    }
    
    data.frame(
      Model = model_name,
      Term = rownames(coefs),
      Estimate = coefs[, "Estimate"],
      Lower_CI = ci[, 1],
      Upper_CI = ci[, 2]
    )
  }))
}
