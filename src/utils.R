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
#' @return A ggplot object displaying a heatmap of missing data patterns.
#' @examples
#' # Create a sample dataset with missing values
#' sample_data <- data.frame(a = c(1, NA, 3, 4), b = c(NA, 2, 3, 4), c = c(1, 2, NA, 4))
#' # Plot missing data patterns
#' plot_missing_data(sample_data, "Missing Completely at Random")
plot_missing_data <- function(data, mechanism_name) {
  # Create a logical matrix indicating missing data
  data_missing <- as.data.frame(sapply(data, is.na))
  data_missing$index <- 1:nrow(data_missing)
  
  # Reshape the data for plotting
  data_missing_melted <- melt(data_missing, id.vars = "index")
  
  # Plot the missing data patterns using ggplot
  ggplot(data_missing_melted, aes(x = index, y = variable, fill = value)) +
    geom_tile() +
    scale_fill_manual(values = c("white", "red")) +
    labs(title = paste("Missing Data Pattern -", mechanism_name), x = "Index", y = "Variable")
}
