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

#' Plot Missing Data Patterns
#'
#' This function visualizes the pattern of missing data in a dataset. It creates a heatmap where
#' missing values are shown in red and observed values are shown in white. The `index` is plotted
#' on the x-axis, representing the rows of the data, and the variables (columns) are shown on the y-axis.
#'
#' @param data A data frame that contains the dataset for which missing data is to be visualized.
#' @param mechanism_name A string to label the missing data plot (e.g., "Missing Completely at Random").
#' @param color_palette A vector of two colors to represent observed and missing values. Defaults to white and red.
#' @return A ggplot object displaying a heatmap of missing data patterns.
#' @examples
#' # Create a sample dataset with missing values
#' sample_data <- data.frame(a = c(1, NA, 3, 4), b = c(NA, 2, 3, 4), c = c(1, 2, NA, 4))
#' # Plot missing data patterns with a custom color palette
#' plot_missing_data(sample_data, "Missing Completely at Random", color_palette = c("white", "red"))
plot_missing_data <- function(data, mechanism_name, color_palette = c("white", "red")) {
  # Create a logical matrix indicating missing data
  data_missing <- as.data.frame(sapply(data, is.na))
  data_missing$index <- 1:nrow(data_missing)
  
  # Reshape the data for plotting
  data_missing_melted <- reshape2::melt(data_missing, id.vars = "index")
  
  # Plot the missing data patterns using ggplot
  ggplot(data_missing_melted, aes(x = index, y = variable, fill = value)) +
    geom_tile() +
    scale_fill_manual(values = color_palette) +
    labs(title = paste("Missing Data Pattern -", mechanism_name), x = "Index", y = "Variable")
}


#' Evaluate Imputation Method
#'
#' This function evaluates an imputation method by performing imputation on two datasets (MCAR and MAR),
#' splitting the data into training and testing sets, and fitting linear regression models. It calculates
#' the Root Mean Squared Error (RMSE) of the predictions for both MCAR and MAR datasets. Additionally,
#' it compares the imputed datasets with the original synthetic data (if provided).
#'
#' @param imputation_function A function that performs imputation on a dataset.
#' @param data_mcar A data frame containing the dataset with Missing Completely at Random (MCAR) data.
#' @param data_mar A data frame containing the dataset with Missing at Random (MAR) data.
#' @param train_index An index vector specifying the training set for model fitting.
#' @param synthetic_data An optional data frame containing the original synthetic dataset for comparison.
#' @return A list containing RMSE values for MCAR and MAR datasets, as well as comparisons with original data (if available).
#' @examples
#' # Assume 'listwise_deletion' is a defined function and synthetic_data exists
#' results <- evaluate_imputation_method(listwise_deletion, data_mcar, data_mar, train_index, synthetic_data)
#' print(results)
evaluate_imputation_method <- function(imputation_function, data_mcar, data_mar, train_index, synthetic_data = NULL) {
  
  # Perform imputation for MCAR and MAR datasets using the provided function
  imputed_result_mcar <- imputation_function(data_mcar)
  imputed_result_mar <- imputation_function(data_mar)
  
  # Split the imputed datasets into training and testing sets
  train_mcar <- imputed_result_mcar[train_index, ]
  test_mcar <- imputed_result_mcar[-train_index, ]
  
  train_mar <- imputed_result_mar[train_index, ]
  test_mar <- imputed_result_mar[-train_index, ]
  
  # Build and evaluate the linear regression models for both MCAR and MAR datasets
  model_mcar <- lm(target ~ ., data = train_mcar)
  predictions_mcar <- predict(model_mcar, test_mcar)
  rmse_mcar <- rmse(test_mcar$target, predictions_mcar)
  
  model_mar <- lm(target ~ ., data = train_mar)
  predictions_mar <- predict(model_mar, test_mar)
  rmse_mar <- rmse(test_mar$target, predictions_mar)
  
  # If synthetic data is provided, compare the imputed results with the original data
  if (!is.null(synthetic_data)) {
    diff_mcar <- compare_imputed_to_original(synthetic_data, imputed_result_mcar)
    diff_mar <- compare_imputed_to_original(synthetic_data, imputed_result_mar)
  } else {
    diff_mcar <- NULL
    diff_mar <- NULL
  }
  
  # Return the evaluation results as a list
  return(list(
    rmse_mcar = rmse_mcar,
    rmse_mar = rmse_mar,
    diff_mcar = diff_mcar,
    diff_mar = diff_mar
  ))
}

#' Create a Bar Plot with Custom Parameters
#'
#' This function generates a bar plot from a data frame with customizable aesthetics. 
#' It supports dynamically labeling bars with rounded values and adding titles and themes.
#'
#' @param data A data frame containing the data to be plotted.
#' @param x_var Character. The name of the variable to be used for the x-axis.
#' @param y_var Character. The name of the variable to be used for the y-axis.
#' @param fill_color Character. The fill color for the bars (e.g., "steelblue").
#' @param title Character. The title for the plot.
#' @param x_label Character. The label for the x-axis. Defaults to "Method".
#' @param y_label Character. The label for the y-axis. Defaults to the name of `y_var`.
#' @param text_vjust Numeric. The vertical adjustment of the text labels above bars. Defaults to -0.5.
#' @return A ggplot object representing the bar plot.
#' @examples
#' data <- data.frame(
#'   Method = c("A", "B", "C"), 
#'   Value = c(10.123, 20.456, 15.789)
#' )
#' create_bar_plot(data, x_var = "Method", y_var = "Value", 
#'                 fill_color = "steelblue", title = "Example Bar Plot")
create_bar_plot <- function(data, x_var, y_var, fill_color, title, 
                            x_label = "Method", y_label = y_var, text_vjust = -0.5) {
  ggplot(data, aes_string(x = x_var, y = y_var)) +
    geom_bar(stat = "identity", fill = fill_color) +
    geom_text(aes_string(label = paste0("round(", y_var, ", 3)")), vjust = text_vjust) +
    labs(title = title,
         x = x_label,
         y = y_label) +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1),
          plot.title = element_text(hjust = 0.5))
}
