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


                    #Ajusted version

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
    #If linear_combination is not a matrix or doesn't have the correct shape, 
    #rowSums may not behave as expected, causing probabilities to be miscalculated. 
    #This results in invalid probabilities for sample(). Ensure that linear_combination is a 
    #matrix with n_samples rows and n_categories columns. Normalize each row 
    #of linear_combination so that the probabilities sum to 1.
    #Matrix multiplication: Ensure linear_combination has one column for each category.
    #Softmax normalization: Properly normalize each row of the probabilities matrix so the values sum to 1.
    #Sampling: Use apply() to sample from each row of the probabilities matrix.
    
      # Generate a matrix for linear combination
      linear_combination <- covariates %*% matrix(runif(n_covariates * n_categories, -1, 1), 
                                                  ncol = n_categories)
      
      # Apply softmax to create probabilities
      probabilities <- exp(linear_combination)
      probabilities <- probabilities / rowSums(probabilities)
      
      # Generate categorical target based on probabilities
      target <- apply(probabilities, 1, function(row) sample(1:n_categories, 1, prob = row))
  } else if (target_type == "spline") {
      library(splines)
      #Ho aggiunto df = 4 per specificare esplicitamente il numero di colonne nella base spline.
      #La funzione rnorm(ncol(spline_basis)) genera un vettore di lunghezza pari al numero di colonne
      #della matrice generata da bs().Questo garantisce che la moltiplicazione avvenga senza problemi.
      
      x <- seq(-3, 3, length.out = n_samples)
      spline_basis <- bs(x, degree = 3, df = 4)  # Numero di gradi di libertà specificati
      
      target <- spline_basis %*% rnorm(ncol(spline_basis)) + rnorm(n_samples, sd = noise_level)
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
