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

#' Evaluate Model Performance on Imputed Data
#'
#' This function evaluates the performance of a linear regression model
#' by training on imputed data and testing on the original test data,
#' calculating the RMSE of predictions.
#'
#' @param imputed_data A data frame containing the imputed dataset for training
#' @param test_data A data frame containing the original test dataset
#' @return A numeric value representing the RMSE of the model predictions
#' @examples
#' rmse_value <- evaluate_model_performance(imputed_data, test_data)
evaluate_model_performance <- function(imputed_data, test_data) {
  # Build linear regression model on imputed data
  model <- lm(target ~ ., data = imputed_data)
  
  # Make predictions on test data
  predictions <- predict(model, test_data)
  
  # Calculate RMSE
  rmse_value <- rmse(test_data$target, predictions)
  
  return(rmse_value)
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
                            x_label = "Method", y_label = NULL, text_vjust = -0.5) {
  # Ensure y_label defaults to y_var if not explicitly set
  y_label <- y_label %||% y_var  
  
  # Preprocess the data for reordering if needed
  if (grepl("reorder", x_var)) {
    matches <- regmatches(x_var, regexec("reorder\\(([^,]+),\\s*([^\\)]+)\\)", x_var))
    if (length(matches[[1]]) == 3) {
      x_var_actual <- matches[[1]][2]
      reorder_by <- matches[[1]][3]
      
      # Perform reordering using base R
      data[[x_var_actual]] <- reorder(data[[x_var_actual]], data[[reorder_by]])
      x_var <- x_var_actual  # Update x_var to use the actual column name
    } else {
      stop("Invalid syntax for reorder in x_var.")
    }
  }
  
  ggplot(data, aes(x = .data[[x_var]], y = .data[[y_var]])) +
    geom_bar(stat = "identity", fill = fill_color) +
    geom_text(aes(label = round(.data[[y_var]], 3)), vjust = text_vjust) +
    labs(title = title,
         x = x_label,
         y = y_label) +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1),
          plot.title = element_text(hjust = 0.5))
}
