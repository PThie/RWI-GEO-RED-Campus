helpers_calculate_percentile_year <- function(
    housing_data = NA,
    var_of_interest = NA,
    percentile = NA
) {
    #' @title Calculate percentile for each year
    #' 
    #' @description This function calculates the specified percentile for a
    #' variable of interest for each year in the housing data.
    #' 
    #' @param housing_data Data frame containing the housing data.
    #' @param var_of_interest String, name of the variable for which the percentile
    #' is to be calculated.
    #' @param percentile Numeric, the percentile to calculate (e.g., 0.99 for the
    #' 99th percentile).
    #' 
    #' @return Data frame with the year and the calculated percentile value.
    #' @author Patrick Thiel
    
    #--------------------------------------------------
    # calculate percentile for each year

    percentile_var_name <- paste0("percentile_value_", percentile)

    percentile_year <- housing_data |>
        dplyr::group_by(ejahr) |>
        dplyr::summarise(
            percentile_value = quantile(
                .data[[var_of_interest]],
                probs = percentile,
                na.rm = TRUE
            )
        ) |>
        as.data.frame()

    #--------------------------------------------------
    # return

    return(percentile_year)
}
