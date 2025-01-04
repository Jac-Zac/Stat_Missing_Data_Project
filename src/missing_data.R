#' Utility functions for introducing missing data into datasets

#' Introduce Missing Completely At Random (MCAR) values
#' @param data Data frame to introduce missing values into
#' @param prop_missing Overall proportion of missing values to introduce
#' @param exclude_cols Vector of column names or indices to exclude from missing value introduction
#' @return Data frame with MCAR missing values
introduce_mcar <- function(data, prop_missing = 0.2, exclude_cols = NULL) {
    data_copy <- data
    
    # Determine which columns to potentially include
    if (!is.null(exclude_cols)) {
        if (is.character(exclude_cols)) {
            cols_to_use <- setdiff(names(data), exclude_cols)
        } else {
            cols_to_use <- setdiff(1:ncol(data), exclude_cols)
        }
    } else {
        cols_to_use <- 1:ncol(data)
    }
    
    # Calculate total number of cells to set as missing
    n_cells <- nrow(data) * length(cols_to_use)
    n_missing <- round(n_cells * prop_missing)
    
    # Create matrix of row-column indices
    indices <- expand.grid(row = 1:nrow(data), col = cols_to_use)
    missing_indices <- indices[sample(1:nrow(indices), n_missing), ]
    
    # Set selected cells to NA
    for (i in 1:nrow(missing_indices)) {
        data_copy[missing_indices$row[i], missing_indices$col[i]] <- NA
    }
    
    return(data_copy)
}

#' Introduce Missing At Random (MAR) values
#' @param data Data frame to introduce missing values into
#' @param prop_missing Overall proportion of missing values to introduce
#' @param predictor_cols Columns used to determine missingness
#' @param target_cols Columns to introduce missing values into
#' @return Data frame with MAR missing values
introduce_mar <- function(data, 
                         prop_missing = 0.2, 
                         predictor_cols = NULL,
                         target_cols = NULL) {
    data_copy <- data
    
    # If no predictor columns specified, use first numeric column
    if (is.null(predictor_cols)) {
        predictor_cols <- names(data)[sapply(data, is.numeric)][1]
    }
    
    # If no target columns specified, use all except predictor columns
    if (is.null(target_cols)) {
        target_cols <- setdiff(names(data), predictor_cols)
    }
    
    # For each predictor column
    for (pred_col in predictor_cols) {
        if (is.numeric(data[[pred_col]])) {
            # Use quantile to determine threshold
            threshold <- quantile(data[[pred_col]], 0.7, na.rm = TRUE)
            missing_rows <- data[[pred_col]] > threshold
        } else {
            # For categorical predictors, randomly select some categories
            cats <- unique(data[[pred_col]])
            selected_cats <- sample(cats, size = length(cats) %/% 2)
            missing_rows <- data[[pred_col]] %in% selected_cats
        }
        
        # Introduce missing values in target columns based on predictor
        for (target_col in sample(target_cols, 
                                size = min(length(target_cols), 
                                         round(length(target_cols) * prop_missing)))) {
            data_copy[missing_rows, target_col] <- NA
        }
    }
    
    return(data_copy)
}

#' Introduce Missing Not At Random (MNAR) values
#' @param data Data frame to introduce missing values into
#' @param prop_missing Overall proportion of missing values to introduce
#' @param threshold_quantile Quantile above which values will be set to missing
#' @return Data frame with MNAR missing values
introduce_mnar <- function(data, 
                          prop_missing = 0.2,
                          threshold_quantile = 0.7) {
    data_copy <- data
    
    # Get numeric columns
    numeric_cols <- names(data)[sapply(data, is.numeric)]
    
    # Number of columns to affect
    n_cols_to_affect <- max(1, round(length(numeric_cols) * prop_missing))
    cols_to_affect <- sample(numeric_cols, n_cols_to_affect)
    
    # For each selected column, introduce missingness based on its own values
    for (col in cols_to_affect) {
        threshold <- quantile(data[[col]], threshold_quantile, na.rm = TRUE)
        data_copy[[col]][data[[col]] > threshold] <- NA
    }
    
    return(data_copy)
}

#' Introduce mixed pattern of missing values
#' @param data Data frame to introduce missing values into
#' @param prop_missing_total Total proportion of missing values desired
#' @param pattern_weights Vector of weights for MCAR, MAR, and MNAR patterns
#' @return Data frame with mixed pattern of missing values
introduce_mixed_missing <- function(data, 
                                  prop_missing_total = 0.2,
                                  pattern_weights = c(MCAR = 0.4, MAR = 0.3, MNAR = 0.3)) {
    data_copy <- data
    
    # Normalize weights
    pattern_weights <- pattern_weights / sum(pattern_weights)
    
    # Calculate proportion for each pattern
    props <- prop_missing_total * pattern_weights
    
    # Introduce each type of missing pattern
    if (props["MCAR"] > 0) {
        data_copy <- introduce_mcar(data_copy, prop_missing = props["MCAR"])
    }
    
    if (props["MAR"] > 0) {
        data_copy <- introduce_mar(data_copy, prop_missing = props["MAR"])
    }
    
    if (props["MNAR"] > 0) {
        data_copy <- introduce_mnar(data_copy, prop_missing = props["MNAR"])
    }
    
    return(data_copy)
}

#' Summarize missing data patterns
#' @param data Data frame to analyze
#' @return List containing missing data summary statistics
summarize_missing <- function(data) {
    # Calculate overall missingness
    total_cells <- prod(dim(data))
    missing_cells <- sum(is.na(data))
    overall_prop <- missing_cells / total_cells
    
    # Calculate missingness by column
    col_missing <- colSums(is.na(data))
    col_prop <- col_missing / nrow(data)
    
    # Calculate missingness by row
    row_missing <- rowSums(is.na(data))
    row_prop <- row_missing / ncol(data)
    
    # Create summary
    summary <- list(
        overall_proportion = overall_prop,
        total_missing = missing_cells,
        # column_proportions = col_prop,
        # row_proportions = row_prop,
        complete_cases = sum(complete.cases(data)),
        incomplete_cases = sum(!complete.cases(data))
    )
    
    return(summary)
}

# # Example usage
# # Introduce different types of missing values
# data_mcar <- introduce_mcar(data, prop_missing = 0.1)
# data_mar <- introduce_mar(data, prop_missing = 0.1)
# data_mnar <- introduce_mnar(data, prop_missing = 0.1)
#
# # Introduce mixed missing pattern
# data_mixed <- introduce_mixed_missing(data,  prop_missing_total = 0.2, pattern_weights = c(MCAR = 0.4, MAR = 0.3, MNAR = 0.3))
#
# # Analyze missing patterns
# missing_summary <- summarize_missing(data_mixed)
# print(missing_summary)
