#' Generate Synthetic Data
#'
#' @param n Number of samples to generate.
#' @param relationship The relationship between `x1` and `x2`. Options: "linear", "quadratic", "cubic", or "log".
#' @param noise_sd Standard deviation of the noise added to the relationship.
#' @param x_range A numeric vector of length 2 specifying the range for `x1`.
#' @param homoscedasticity Boolean indicating if the noise is homoschedastic, if FALSE add linear noise
#' @param min_sd_noise Numeric specifying min noise when homoschedastic is FALSE
#' @param balanced Boolean indicating if the dataset is balance, if FALSE use beta distribution
#' @param alpha numeric for beta distributio
#' @param beta numeric for beta distribution
#' @return A data frame with two columns: `x1` (independent variable) and `x2` (dependent variable).
#' @details The function generates synthetic data with a specified relationship between `x1` and `x2`, adding noise to simulate real-world variability. If the `relationship` is "log", `x_range` must ensure positive values for `x1`.
#' @examples
#' # Generate data with a linear relationship
#' data <- generate_data(n = 100, relationship = "linear", noise_sd = 0.1)
#' 
#' # Generate data with a quadratic relationship
#' data <- generate_data(n = 100, relationship = "quadratic", noise_sd = 0.2, x_range = c(-2, 2))
generate_data <- function(n, 
                          relationship = "linear", 
                          noise_sd = 0.1, 
                          x_range = c(-1, 1), 
                          homoscedasticity = TRUE, min_sd_noise = 0,
                          balanced = TRUE, alpha = 2, beta = 5) {
  
  
  # Generate random noise
  if(homoscedasticity == TRUE){
    eps <- rnorm(n, 0, noise_sd) 
  } else {
    eps <- rnorm(n, mean = 0, sd = seq(min_sd_noise, noise_sd, length.out = n))
  }
  
  if(balanced == TRUE) {
    x1 <- runif(n, x_range[1], x_range[2])  # Balanced, uniform distribution
  } else {
    # Unbalanced, Beta distribution
    beta_values <- rbeta(n, shape1 = alpha, shape2 = beta)
    # Rescale to the desired range [x_range[1], x_range[2]]
    x1 <- x_range[1] + (x_range[2] - x_range[1]) * beta_values
  }
  # ugly workaround for summing linear eps after
  x1 <- sort(x1)
  
  # Compute x2 based on the specified relationship
  x2 <- switch(relationship,
               "linear" = x1 + eps,
               "quadratic" = x1^2 + eps,
               "cubic" =  5 * x1^3 + 3 * x1^2 + eps,
               "log" = {
                 if (x_range[1] <= 0) stop("X range must be positive for log relationship")
                 3 * log(x1) + eps
               },
               "piecewise" = {
                 pivot <- (x_range[2] + x_range[1]) / 2
                 
                 # Create the dependent variable x2 using a piecewise structure
                 x2 <- ifelse(x1 < pivot, 
                              runif(1, min = -10, max = 10) + runif(1, min = -10, max = 10) * x1,    # For x1 < pivot
                              runif(1, min = -10, max = 10) + runif(1, min = -10, max = 10) * x1)    # For x1 >= pivot
                 x2 = x2 + eps
               })
  
  # Return the generated data as a data frame
  data.frame(x1 = x1, x2 = x2)
}

#' Synthetic Dataset Generator
#'
#' @param n_samples Number of samples to generate (rows).
#' @param n_covariates Number of covariates to generate (columns).
#' @param correlation Type of correlation between covariates: "linear", "polynomial", or "complex".
#' @param target_type Type of target variable: "linear", "polynomial", "categorical", or "spline".
#' @param n_categories Number of categories if `target_type` is "categorical".
#' @param noise_level Standard deviation of noise to add to the target variable.
#' @return A dataframe containing the generated dataset (`data`) and the target variable (`target`).
#' @examples
#' # Generate a dataset with 100 samples, 5 covariates, and a linear target
#' dataset <- synthetic_dataset_gen(
#'   n_samples = 100,
#'   n_covariates = 5,
#'   correlation = "linear",
#'   target_type = "linear"
#' )
#' head(dataset$data)
#' head(dataset$target)
synthetic_dataset_gen <- function(n_samples, n_covariates, correlation = "linear", 
                                  target_type = "linear", n_categories = 3, noise_level = 1.0) {
  
  # Validate inputs
  if (n_samples <= 0 || n_covariates <= 0) 
    stop("n_samples and n_covariates must be positive integers.")
  if (!correlation %in% c("linear", "polynomial", "complex","none")) 
    stop("Invalid correlation type.")
  if (!target_type %in% c("linear", "polynomial", "categorical", "spline")) 
    stop("Invalid target type.")
  
  # Generate covariates
  covariates <- matrix(rnorm(n_samples * n_covariates), nrow = n_samples, ncol = n_covariates)
  
  # Add correlation between covariates
  if (correlation == "linear") {
    covariates <- covariates %*% matrix(rnorm(n_covariates^2, sd = 0.5), n_covariates, n_covariates)
  } else if (correlation == "polynomial") {
    covariates <- covariates^2 + covariates^3
  } else if (correlation == "complex") {
    covariates <- sin(covariates) + cos(covariates^2)
  } else if (correlation == "none") { }
  
  # Generate target variable
  if (target_type == "linear") {
    # Linear relationship
    beta <- runif(n_covariates, -1, 1)
    target <- covariates %*% beta + rnorm(n_samples, sd = noise_level)
  } else if (target_type == "polynomial") {
    # Polynomial relationship
    beta <- runif(n_covariates, -1, 1)
    target <- covariates %*% beta + (covariates %*% beta)^2 + rnorm(n_samples, sd = noise_level)
  } else if (target_type == "categorical") {
    # Categorical target with softmax normalization
    linear_combination <- covariates %*% matrix(runif(n_covariates * n_categories, -1, 1), 
                                                ncol = n_categories)
    probabilities <- exp(linear_combination)
    probabilities <- probabilities / rowSums(probabilities)
    target <- apply(probabilities, 1, function(row) sample(1:n_categories, 1, prob = row))
  } else if (target_type == "spline") {
    # Spline-based target
    library(splines)
    x <- seq(-3, 3, length.out = n_samples)
    spline_basis <- bs(x, degree = 3, df = 4)
    target <- spline_basis %*% rnorm(ncol(spline_basis)) + rnorm(n_samples, sd = noise_level)
  }
  
  # Return as a dataframe
  return(data.frame(covariates, target = target))
}


# Example usage
# synthetic_dataset_gen( n_samples = 100, n_covariates = 5, correlation = "linear", target_type = "linear", noise_level = 0.5, seed = 42)
