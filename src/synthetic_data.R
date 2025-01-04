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

#' Generate data with non-linear relationships
#' @param n_samples Number of samples to generate
#' @param pattern Type of non-linear pattern ("polynomial", "sinusoidal", "exponential")
#' @param noise_std Standard deviation of noise
#' @return A data frame containing the synthetic data with non-linear relationships
generate_nonlinear_data <- function(n_samples = 100, pattern = "polynomial", noise_std = 0.1) {
    
    # Generate feature
    x <- seq(-3, 3, length.out = n_samples)
    
    # Generate response based on pattern
    y <- switch(pattern,
        "polynomial" = 1 + 2*x + 0.5*x^2 - 0.1*x^3,
        "sinusoidal" = sin(x) + 0.5*cos(2*x),
        "exponential" = exp(0.5*x),
        stop("Invalid pattern specified")
    )
    
    # Add noise
    y <- y + rnorm(n_samples, mean = 0, sd = noise_std)
    
    # Create data frame
    data <- data.frame(x = x, y = y)
    
    return(data)
}

#' Generate data with clusters
#' @param n_clusters Number of clusters to generate
#' @param n_per_cluster Number of samples per cluster
#' @param cluster_std Standard deviation within clusters
#' @return A data frame containing clustered data
generate_cluster_data <- function(n_clusters = 3, n_per_cluster = 50, cluster_std = 0.5) {
    n_samples <- n_clusters * n_per_cluster
    
    # Generate cluster centers
    centers <- matrix(rnorm(n_clusters * 2, sd = 2), ncol = 2)
    
    # Generate samples around centers
    data <- matrix(0, nrow = n_samples, ncol = 2)
    labels <- numeric(n_samples)
    
    for(i in 1:n_clusters) {
        idx <- ((i-1)*n_per_cluster + 1):(i*n_per_cluster)
        data[idx,] <- matrix(rnorm(n_per_cluster * 2, sd = cluster_std), ncol = 2) + 
                      matrix(centers[i,], nrow = n_per_cluster, ncol = 2, byrow = TRUE)
        labels[idx] <- i
    }
    
    # Convert to data frame
    data <- data.frame(X1 = data[,1], X2 = data[,2], cluster = as.factor(labels))
    
    return(data)
}


# Example usage
# # Generate random data with 3 continuous and 2 categorical variables
# random_data <- generate_random_data(n_samples = 100,  n_continuous = 3,
#                                     n_categorical = 2, n_categories= c(2, 3))
#
# # Generate data with linear relationship
# linear_data <- generate_linear_data(n_samples = 200,  coefficients = c(2, -1, 0.5))
#
# # Generate clustered data
# cluster_data <- generate_cluster_data(n_clusters = 4,  n_per_cluster = 50)
