#' Utility functions for introducing missing data into datasets

#' Introduce Missing Completely At Random (MCAR) values
#' @param data Data frame to introduce missing values into
#' @param prop_missing Overall proportion of missing values to introduce
#' @param exclude_cols Vector of column names or indices to exclude from missing value introduction
#' @return Data frame with MCAR missing values
introduce_mcar <- function(data, prop_missing = 0.2, exclude_cols = NULL) {
    if (prop_missing < 0 || prop_missing > 1) {
        stop("prop_missing must be between 0 and 1")
    }
    
    data_copy <- data
    cols_to_use <- if (!is.null(exclude_cols)) {
        if (is.character(exclude_cols)) setdiff(names(data), exclude_cols) else setdiff(seq_len(ncol(data)), exclude_cols)
    } else {
        seq_len(ncol(data))
    }
    
    n_missing <- round(prop_missing * nrow(data) * length(cols_to_use))
    flat_indices <- sample(seq_len(nrow(data) * length(cols_to_use)), n_missing)
    data_copy[as.matrix(expand.grid(row = 1:nrow(data), col = cols_to_use))[flat_indices, ]] <- NA
    
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

    if (prop_missing < 0 || prop_missing > 1) {
        stop("prop_missing must be between 0 and 1")
    }
    
    data_copy <- data
    
    # Default to numeric columns for predictors
    if (is.null(predictor_cols)) {
        predictor_cols <- names(data)[sapply(data, is.numeric)]
        if (length(predictor_cols) == 0) {
            stop("No numeric columns found for predictors")
        }
    }
    
    # Default to all other columns for targets
    if (is.null(target_cols)) {
        target_cols <- setdiff(names(data), predictor_cols)
        if (length(target_cols) == 0) {
            stop("No target columns available for introducing missing values")
        }
    }
    
    for (pred_col in predictor_cols) {
        if (is.numeric(data[[pred_col]])) {
            threshold <- quantile(data[[pred_col]], 0.7, na.rm = TRUE)
            missing_rows <- data[[pred_col]] > threshold
        } else {
            cats <- unique(data[[pred_col]])
            selected_cats <- sample(cats, size = length(cats) %/% 2)
            missing_rows <- data[[pred_col]] %in% selected_cats
        }
        
        for (target_col in target_cols) {
            # Proportion control per target column
            if (sum(missing_rows) > 0) {
                n_missing <- round(sum(missing_rows) * prop_missing)
                missing_rows[sample(which(missing_rows), size = n_missing)] <- FALSE
            }
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

    if (prop_missing < 0 || prop_missing > 1) {
        stop("prop_missing must be between 0 and 1")
    }
    
    data_copy <- data
    numeric_cols <- names(data)[sapply(data, is.numeric)]
    
    if (length(numeric_cols) == 0) {
        stop("No numeric columns available for MNAR introduction")
    }
    
    n_missing_total <- round(prop_missing * nrow(data) * length(numeric_cols))
    n_cols_to_affect <- max(1, round(length(numeric_cols) * prop_missing))
    cols_to_affect <- sample(numeric_cols, n_cols_to_affect)
    
    for (col in cols_to_affect) {
        threshold <- quantile(data[[col]], threshold_quantile, na.rm = TRUE)
        missing_rows <- which(data[[col]] > threshold)
        n_missing <- min(length(missing_rows), round(n_missing_total / n_cols_to_affect))
        data_copy[sample(missing_rows, n_missing), col] <- NA
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

    if (prop_missing_total < 0 || prop_missing_total > 1) {
        stop("prop_missing_total must be between 0 and 1")
    }
    
    if (sum(pattern_weights) == 0) {
        stop("Pattern weights cannot all be zero")
    }
    
    data_copy <- data
    pattern_weights <- pattern_weights / sum(pattern_weights)
    props <- prop_missing_total * pattern_weights
    
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
    total_cells <- prod(dim(data))
    missing_cells <- sum(is.na(data))
    overall_prop <- missing_cells / total_cells
    
    col_missing <- colSums(is.na(data))
    col_prop <- col_missing / nrow(data)
    row_missing <- rowSums(is.na(data))
    row_prop <- row_missing / ncol(data)
    
    summary <- list(
        overall_proportion = overall_prop,
        total_missing = missing_cells,
#        column_proportions = col_prop,
#        row_proportions = row_prop,
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
