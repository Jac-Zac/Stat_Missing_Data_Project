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

#' Create Imputation Comparison Plot
#'
#' This function creates a scatter plot comparing original and imputed data points.
#' It visualizes the relationship between two variables (x1 and x2), distinguishing
#' between original complete cases and imputed values through different colors and sizes.
#'
#' @param data A data frame containing the original dataset with missing values
#' @param imputed_data A data frame containing the imputed dataset
#' @param title A string specifying the plot title
#' @return A ggplot object displaying the comparison between original and imputed values
#' @examples
#' # Create sample data with missing values
#' original_data <- data.frame(x1 = c(1, 2, 3, 4), x2 = c(NA, 2, 3, NA))
#' imputed_data <- data.frame(x1 = c(1, 2, 3, 4), x2 = c(1.5, 2, 3, 3.5))
#' # Create comparison plot
#' create_imputation_plot(original_data, imputed_data, "Imputation Results")
create_imputation_plot <- function(data, imputed_data, title) {
    # Create complete cases dataset from original data
    complete_cases <- data.frame(
        x1 = data$x1[!is.na(data$x2)],
        x2 = data$x2[!is.na(data$x2)],
        type = "Original"
    )
    
    # Create imputed cases dataset from imputed values
    imputed_cases <- data.frame(
        x1 = data$x1[is.na(data$x2)],
        x2 = imputed_data$x2[is.na(data$x2)],
        type = "Imputed"
    )
    
    # Combine the datasets for plotting
    plot_data <- rbind(complete_cases, imputed_cases)
    
    # Create the plot with increased text and point sizes
    ggplot(plot_data, aes(x = x1, y = x2, color = type)) +
        geom_point(size = ifelse(plot_data$type == "Imputed", 4, 3)) +  # Increased point sizes
        scale_color_manual(values = c("Imputed" = "#bf616a", "Original" = "black")) +
        labs(title = title,
             x = "x1",
             y = "x2",
             color = "Data Type") +
        theme_minimal() +
        theme(
            plot.title = element_text(hjust = 0.5, size = 18),  # Increased title size
            axis.title = element_text(size = 14),  # Increased axis title size
            axis.text = element_text(size = 12),   # Increased axis text size
            legend.text = element_text(size = 14)  # Increased legend text size
        )
}
