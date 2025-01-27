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
            plot.title = element_text(hjust = 0.5, size = 20),  # Increased title size
            axis.title = element_text(size = 18),  # Increased axis title size
            axis.text = element_text(size = 16),   # Increased axis text size
            legend.text = element_text(size = 16)  # Increased legend text size
        )
}

#' Create Residuals vs Leverage Plot
#'
#' This function creates a residuals vs leverage plot with Cook's distance curves.
#' It visualizes leverage, studentized residuals, and diagnostic curves for model assessment.
#'
#' @param model A linear model object
#' @param custom_line_color A custom color for the line 
#' @return A ggplot object showing the residuals vs leverage plot
residuals_vs_leverage_plot <- function(model, custom_line_color) {
  
  # Compute diagnostics used by plot.lm(which = 5)
  h      <- hatvalues(model)      # Leverages
  rstud  <- rstudent(model)       # Studentized residuals
  p      <- length(coef(model))   # Number of parameters in the model
  n      <- length(rstud)         # Number of observations
  
  # Build the base data frame for scatter plot
  df <- data.frame(
    Leverage   = h,
    RStudent   = rstud
  )

  # Generate Cook’s distance reference curves
  cooks_vals <- c(0.5, 1.0)
  h_seq <- seq(min(h[h > 1e-5]), max(h), length.out = 200)  # Avoid division by zero
  
  # Helper function to create Cook's distance curves
  make_cooks_curve <- function(Dval) {
    y <- sqrt(Dval * p * (1 - h_seq)/h_seq)
    pos <- data.frame(Leverage = h_seq, RStudent =  y, CookDist = Dval)
    neg <- data.frame(Leverage = h_seq, RStudent = -y, CookDist = Dval)
    rbind(pos, neg)
  }
  
  cooks_df <- do.call(rbind, lapply(cooks_vals, make_cooks_curve))

  # Create the residuals vs leverage plot
  ggplot(df, aes(x = Leverage, y = RStudent)) +
      geom_point(shape = 1, color = "black") +                      
      geom_smooth(method = "loess", formula = y ~ x, se = FALSE, color = custom_line_color) +
      geom_hline(yintercept = 0, linetype = "dotted") +             
      labs(
          title = "Residuals vs Leverage",
          x     = "Leverage",
          y     = "Studentized Residuals"
      ) +
      theme_bw()
}

#' Create Diagnostic Plots for a Linear Model
#'
#' This function creates four diagnostic plots to evaluate a linear model's fit:
#' Residuals vs Fitted, Scale-Location, Normal Q-Q, and Residuals vs Leverage.
#'
#' @param model A linear model object
#' @param custom_line_color A custom color for the line
#' @return A patchwork object combining four diagnostic plots
my_diagnostic_plots <- function(model, data, custom_line_color = "blue") {
 suppressMessages(library(patchwork))
  # Prepare data for each diagnostic plot
  fitted_values           <- predict(model)
  residuals               <- resid(model)
  standardized_residuals  <- rstandard(model)
  cooks_d                 <- cooks.distance(model)
  
  # Create data frames for each plot
  df1 <- data.frame(Fitted = fitted_values, Residual = residuals)
  df2 <- data.frame(Fitted = fitted_values, Sqrt_Abs_Std_Residuals = sqrt(abs(standardized_residuals)))
  df3 <- data.frame(Standardized_Residuals = standardized_residuals)
  
  # Residuals vs Fitted plot
  p1 <- ggplot(df1, aes(x = Fitted, y = Residual)) +
    geom_point(shape = 1, color = "black") +
    geom_smooth(method = "loess", formula = y ~ x, se = FALSE, color = custom_line_color) +
    labs(title = "Residuals vs Fitted", x = "Fitted Values", y = "Residuals") +
    theme_bw()
  
  # Scale-Location plot
  p2 <- ggplot(df2, aes(x = Fitted, y = Sqrt_Abs_Std_Residuals)) +
    geom_point(shape = 1, color = "black") +
    geom_smooth(method = "loess", formula = y ~ x, se = FALSE, color = custom_line_color) +
    labs(title = "Scale-Location", x = "Fitted Values", y = expression(sqrt("|Standardized Residuals|"))) +
    theme_bw()
 
  # Normal Q-Q plot
  p3 <- ggplot(df3, aes(sample = Standardized_Residuals)) +
    stat_qq(shape = 1, color = "black") +
    stat_qq_line(color = custom_line_color) +
    labs(title = "Normal Q-Q", x = "Theoretical Quantiles", y = "Std. Residuals") +
    theme_bw()
  
  # Residuals vs Leverage plot
  p4 <- residuals_vs_leverage_plot(model, custom_line_color)
  
  # Combine and return the diagnostic plots
  combined_plot <- (p1 | p2) / (p3 | p4)
  return(combined_plot)
}

#' Utility Function to Plot Coefficients
#'
#' @param data A data frame containing the coefficient estimates and confidence intervals. 
#'             It should have columns: `Term`, `Estimate`, `Lower_CI`, `Upper_CI`, and `Model`.
#' @param title A string representing the title of the plot.
#' @param y_limits Optional numeric vector of length 2 specifying the limits for the y-axis.
#' @param palette A string indicating the color palette to use for the plot. Default is "aurora".
#' @return A ggplot object visualizing the coefficient estimates with error bars.
plot_coefficients <- function(data, title, y_limits = NULL, palette = "aurora") {
  ggplot(data, aes(x = Term, y = Estimate, color = Model)) +
    geom_point(position = position_dodge(width = 0.5), size = 3) +
    geom_errorbar(aes(ymin = Lower_CI, ymax = Upper_CI), width = 0.2, position = position_dodge(width = 0.5)) +
    labs(title = title,
         x = "Coefficient Terms",
         y = "Coefficient Estimate") +
    scale_color_nord(palette) +  # Use the specified color palette
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    (if (!is.null(y_limits)) scale_y_continuous(limits = y_limits) else NULL)
}

#' Create Distribution Metrics Comparison Plot
#'
#' @param metrics_list A named list where each name corresponds to a method, and each value is a list containing `wasserstein` and `jsd` metrics
#' @return A ggplot object for the comparison
create_distribution_metrics_plot <- function(original_data, imputed_datasets) {
  # Function to calculate the metrics for each imputed dataset
  metrics_list <- lapply(imputed_datasets, function(imputed_data) {
    # Assuming `original_data` is your original (non-imputed) dataset
    compare_distributions(original_data, imputed_data, metrics = c("wasserstein", "jsd"))
  })


  # Extract methods and metrics
  methods <- names(metrics_list)
  metrics_df <- do.call(rbind, lapply(methods, function(method) {
    data.frame(
      Method = method,
      Metric_Type = c("Wasserstein", "JSD"),
      Value = c(metrics_list[[method]]$wasserstein, metrics_list[[method]]$jsd)
    )
  }))
  
  # Create the plot
  ggplot(metrics_df, aes(x = reorder(Method, Value), y = Value)) +
    geom_bar(stat = "identity", fill = "#5E81AC") +
    geom_text(aes(label = round(Value, 3)), vjust = -0.5, size = 6) +  # Increased size for text labels
    facet_wrap(~Metric_Type, scales = "free_y", ncol = 2) +
    labs(title = "Distribution Metrics Comparison", x = "Method", y = "Metric Value") +
    theme_minimal() +
    theme(
      axis.text.x = element_text(angle = 45, hjust = 1, size = 16),   # Increased size for x-axis text
      # axis.text.x = element_text(angle = 90, hjust = 1, size = 16),   # Increased size for x-axis text
      axis.text.y = element_text(size = 14),                          # Increased size for y-axis text
      axis.title.x = element_text(size = 18),                         # Increased size for x-axis title
      axis.title.y = element_text(size = 18),                         # Increased size for y-axis title
      plot.title = element_text(size = 24, hjust = 0.5),              # Increased size for plot title
      strip.text = element_text(size = 18, face = "bold"),            # Increased size for facet labels
      strip.background = element_rect(fill = "#E5E9F0", color = NA),
      panel.spacing = unit(2, "lines")
    )
}

#' Plot Comparison of Different Imputation Methods and Distribution Metrics
#'
#' @param original_data A data frame containing the original complete dataset
#' @param missing_data A data frame containing the dataset with missing values
#' @param imputation_methods A named list containing the imputation methods and corresponding functions
#' @return A list containing two elements: a list of individual plots comparing the imputation methods and the distribution metrics plot
#'
plot_imputations_and_metrics <- function(original_data, missing_data, imputation_methods) {
  # Create a list to store the imputed datasets
  imputed_datasets <- list()
  
  # Create a list to store the individual plots for each method
  plots <- lapply(names(imputation_methods), function(method_name) {
    if (method_name == "Original Dataset") {
      # Use the original_data directly for the "Original Dataset" method
      imputed_data <- original_data
    } else {
      # Apply the imputation method to the missing_data for other methods
      imputed_data <- imputation_methods[[method_name]](missing_data)
    }
    
    # Store the imputed dataset in the list with method name as key
    imputed_datasets[[method_name]] <<- imputed_data  # Use global assignment to ensure persistence

    # Create a plot comparing the imputed_data to the original_data
    create_imputation_plot(
      data = missing_data,            # Pass the dataset with missing values
      imputed_data = imputed_data,    # Pass the imputed dataset (or original data)
      title = paste("Imputation Method:", method_name)  # Add method name to the title
    )
  })
  
  # Create the metrics distribution plot using the imputed datasets
  metrics_plot <- create_distribution_metrics_plot(original_data, imputed_datasets)
  
  # Return both the list of individual plots and the metrics plot
  return(list(
    imputation_plots = plots,        # Return the list of individual plots
    metrics_plot = metrics_plot      # Return the distribution metrics plot
  ))
}
