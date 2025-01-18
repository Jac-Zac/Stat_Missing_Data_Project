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


#' Plot Comparison of Different Imputation Methods
#'
#' This function generates comparison plots for various imputation methods,
#' showing how each imputation method addresses missing data in a dataset.
#' It performs multiple imputations, creates individual plots for each method,
#' and arranges the plots in a grid for easy comparison.
#'
#' @param original_data A data frame containing the original complete dataset
#' @param missing_data A data frame containing the dataset with missing values
#' @return A grid of plots comparing the different imputation methods
#' @examples
#' plot_all_imputations(original_data, missing_data)
#'
plot_all_imputations <- function(original_data, missing_data) {
  # Perform mean imputation
  mean_imp <- simple_imputation(missing_data, "mean")
  
  # Perform k-Nearest Neighbors (kNN) imputation
  knn_imp <- kNN(missing_data, variable = "x2")
  
  # Perform regression-based imputation
  reg_imp <- regression_imputation(missing_data)
  
  # Perform hot deck imputation
  hotdeck_imp <- hot_deck_imputation(missing_data)
  
  # Perform Expectation-Maximization (EM) imputation
  em_imp <- impute_EM(missing_data)
  
  # Perform Generalized Additive Model (GAM) based imputation
  gam_imp <- gam_based_imputation(missing_data)
  
  # Perform Random Forest-based imputation
  forest_imp <- tree_based_imputation(missing_data)

  # Create individual plots for each imputation method
  plots <- list(
    create_imputation_plot(missing_data, mean_imp, "Mean Imputation"),
    create_imputation_plot(missing_data, knn_imp, "kNN Imputation"),
    create_imputation_plot(missing_data, reg_imp, "Regression Imputation"),
    create_imputation_plot(missing_data, hotdeck_imp, "Hot Deck Imputation"),
    create_imputation_plot(missing_data, em_imp, "EM Imputation"),
    create_imputation_plot(missing_data, gam_imp, "GAM Imputation"),
    create_imputation_plot(missing_data, forest_imp, "Random Forest Imputation")
  )

  # Arrange all plots in a grid with 2 columns
  grid.arrange(grobs = plots, ncol = 2)
}
