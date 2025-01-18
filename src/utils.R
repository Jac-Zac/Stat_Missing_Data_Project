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
