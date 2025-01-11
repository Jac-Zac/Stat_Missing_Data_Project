#' Utility functions for generating synthetic data with different patterns and characteristics

#' Generate completely random data with specified continuous and categorical features
#' @param n_samples Number of samples to generate
#' @param n_continuous Number of continuous features
#' @param n_categorical Number of categorical features
#' @param n_categories Vector specifying number of categories for each categorical variable
#' @return A data frame containing the synthetic data
generate_random_data <- function(n_samples = 100, 
                               n_continuous = 3, 
                               n_categorical = 2,
                               n_categories = c(3, 4)) {
    
    # Generate continuous features
    continuous_data <- matrix(rnorm(n_samples * n_continuous), nrow = n_samples)
    colnames(continuous_data) <- paste0("cont_", 1:n_continuous)
    
    # Generate categorical features
    categorical_data <- matrix(NA, nrow = n_samples, ncol = n_categorical)
    for(i in 1:n_categorical) {
        categorical_data[,i] <- sample(paste0("cat_", 1:n_categories[i]), n_samples, replace = TRUE)
    }

    colnames(categorical_data) <- paste0("factor_", 1:n_categorical)
    
    # Combine and convert to data frame
    data <- data.frame(continuous_data, categorical_data)
    
    # Convert categorical columns to factors
    for(i in (n_continuous + 1):(n_continuous + n_categorical)) {
        data[,i] <- as.factor(data[,i])
    }
    
    return(data)
}

#' Generate data with linear relationships
#' @param n_samples Number of samples to generate
#' @param coefficients Vector of coefficients for linear relationship
#' @param noise_std Standard deviation of noise
#' @param include_interaction Boolean to include interaction terms
#' @return A data frame containing the synthetic data with linear relationships
generate_linear_data <- function(n_samples = 100, 
                               coefficients = c(2, -1, 0.5), 
                               noise_std = 0.1,
                               include_interaction = FALSE) {
    
    n_features <- length(coefficients)
    
    # Generate feature matrix
    X <- matrix(rnorm(n_samples * n_features), nrow = n_samples)
    colnames(X) <- paste0("X", 1:n_features)
    
    # Generate response variable
    y <- X %*% coefficients
    
    # Add interaction term if requested
    if(include_interaction) {
        interaction <- X[,1] * X[,2]
        y <- y + 0.5 * interaction
    }
    
    # Add noise
    y <- y + rnorm(n_samples, mean = 0, sd = noise_std)
    
    # Combine into data frame
    data <- data.frame(X)
    data$y <- as.vector(y)
    
    return(data)
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
  if (n_samples <= 0 || n_covariates <= 0) stop("n_samples and n_covariates must be positive integers.")
  if (!correlation %in% c("linear", "polynomial", "complex")) stop("Invalid correlation type.")
  if (!target_type %in% c("linear", "polynomial", "categorical", "spline")) stop("Invalid target type.")

  # Generate covariates
  covariates <- matrix(rnorm(n_samples * n_covariates), nrow = n_samples, ncol = n_covariates)

  # Add correlation between covariates
  if (correlation == "linear") {
    covariates <- covariates %*% matrix(rnorm(n_covariates^2, sd = 0.5), n_covariates, n_covariates)
  } else if (correlation == "polynomial") {
    covariates <- covariates^2 + covariates^3
  } else if (correlation == "complex") {
    covariates <- sin(covariates) + cos(covariates^2)
  }

  # Generate target variable
  if (target_type == "linear") {
    beta <- runif(n_covariates, -1, 1)
    target <- covariates %*% beta + rnorm(n_samples, sd = noise_level)
  } else if (target_type == "polynomial") {
    beta <- runif(n_covariates, -1, 1)
    target <- covariates %*% beta + (covariates %*% beta)^2 + rnorm(n_samples, sd = noise_level)
  } else if (target_type == "categorical") {
    linear_combination <- covariates %*% runif(n_covariates, -1, 1)
    probabilities <- exp(linear_combination) / rowSums(exp(linear_combination))
    target <- apply(probabilities, 1, function(row) sample(1:n_categories, 1, prob = row))
  } else if (target_type == "spline") {
    library(splines)
    x <- seq(-3, 3, length.out = n_samples)
    target <- bs(x, degree = 3) %*% rnorm(4) + rnorm(n_samples, sd = noise_level)
  }

  # Return as a dataframe
  return(data.frame(covariates, target = target))
}


# synthetic_dataset_gen( n_samples = 100, n_covariates = 5, correlation = "linear", target_type = "linear", noise_level = 0.5, seed = 42)


# Example usage
# # Generate random data with 3 continuous and 2 categorical variables
# random_data <- generate_random_data(n_samples = 100,  n_continuous = 3, n_categorical = 2, n_categories= c(2, 3))
#
# # Generate data with linear relationship
# linear_data <- generate_linear_data(n_samples = 200,  coefficients = c(2, -1, 0.5))
#
# # Generate clustered data
# cluster_data <- generate_cluster_data(n_clusters = 4,  n_per_cluster = 50)
