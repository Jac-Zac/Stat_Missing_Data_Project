#' List-wise or Case Deletion
#' @param data Data frame with missing values
#' @return Data frame with rows containing missing values removed
listwise_deletion <- function(data) {
  return(na.omit(data))
}

#' Pairwise Deletion
#' @param data Data frame with missing values
#' @return Covariance matrix computed using pairwise deletion
pairwise_deletion <- function(data) {
  complete_cases <- complete.cases(data)
  return(cov(data[complete_cases, , drop = FALSE]))
}

#' Simple Imputation (Mean)
#' @param data Data frame with missing values
#' @return Data frame with missing values replaced by column means
simple_imputation <- function(data) {
  for (col in names(data)) {
    if (is.numeric(data[[col]])) {
      data[[col]][is.na(data[[col]])] <- mean(data[[col]], na.rm = TRUE)
    }
  }
  return(data)
}

#' Regression Imputation
#' @param data Data frame with missing values
#' @return Data frame with missing values imputed using regression
regression_imputation <- function(data) {
  for (col in names(data)) {
    if (any(is.na(data[[col]])) && is.numeric(data[[col]])) {
      complete_data <- data[complete.cases(data), ]
      incomplete_rows <- which(is.na(data[[col]]))
      model <- lm(data[[col]] ~ ., data = complete_data)
      predictions <- predict(model, newdata = data[incomplete_rows, , drop = FALSE])
      data[[col]][incomplete_rows] <- predictions
    }
  }
  return(data)
}

#' Hot-deck Imputation
#' @param data Data frame with missing values
#' @return Data frame with missing values imputed using hot-deck imputation
hot_deck_imputation <- function(data) {
  for (col in names(data)) {
    if (any(is.na(data[[col]]))) {
      non_missing_values <- data[[col]][!is.na(data[[col]])]
      data[[col]][is.na(data[[col]])] <- sample(non_missing_values, sum(is.na(data[[col]])), replace = TRUE)
    }
  }
  return(data)
}

#' Expectation-Maximization Imputation
#' @param data Data frame with missing values
#' @return Data frame with missing values imputed using a simple EM-like approach
em_imputation <- function(data) {
  tol <- 1e-6
  max_iter <- 100
  iter <- 0
  prev_data <- data
  while (iter < max_iter) {
    iter <- iter + 1
    for (col in names(data)) {
      if (is.numeric(data[[col]]) && any(is.na(data[[col]]))) {
        data[[col]][is.na(data[[col]])] <- mean(data[[col]], na.rm = TRUE)
      }
    }
    if (max(abs(as.matrix(data) - as.matrix(prev_data)), na.rm = TRUE) < tol) {
      break
    }
    prev_data <- data
  }
  return(data)
}

#' Multiple Imputation
#' @param data Data frame with missing values
#' @return List of imputed data frames
multiple_imputation <- function(data, m = 5) {
  imputations <- vector("list", m)
  for (i in seq_len(m)) {
    imputations[[i]] <- simple_imputation(data)
  }
  return(imputations)
}

# Example usage
# listwise_result <- listwise_deletion(data_with_na)
# pairwise_result <- pairwise_deletion(data_with_na)
# simple_result <- simple_imputation(data_with_na)
# regression_result <- regression_imputation(data_with_na)
# hotdeck_result <- hot_deck_imputation(data_with_na)
# em_result <- em_imputation(data_with_na)
# multiple_result <- multiple_imputation(data_with_na)
