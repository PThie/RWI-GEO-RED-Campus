helpers_combining_percentile_calculations <- function(
    housing_data = NA,
    var_of_interest = NA,
    top_perc = NA,
    bottom_perc = NA
) {
    #' @title Combine percentile calculations
    #' 
    #' @description This function combines the calculations of the top and bottom
    #' percentiles for housing data.
    #' 
    #' @param housing_data Data frame containing the housing data.
    #' @param var_of_interest String, name of the variable for which the percentile
    #' is to be calculated.
    #' @param top_perc Numeric, the top percentile to calculate (e.g., 0.99 for the
    #' 99th percentile).
    #' @param bottom_perc Numeric, the bottom percentile to calculate (e.g., 0.01 for
    #' the 1st percentile).
    #' 
    #' @return Data frame containing the top and bottom percentiles for each year.
    #' @author Patrick Thiel

    #--------------------------------------------------
    # calculate top and bottom percentile

    top_perc <- helpers_calculate_percentile_year(
        housing_data = housing_data,
        var_of_interest = var_of_interest,
        percentile = top_perc
    )

    bottom_perc <- helpers_calculate_percentile_year(
        housing_data = housing_data,
        var_of_interest = var_of_interest,
        percentile = bottom_perc
    )

    #--------------------------------------------------
    # combine top and bottom percentiles

    percs <- merge(
        top_perc,
        bottom_perc,
        by = "ejahr",
        suffixes = c("_top", "_bottom")
    )

    #--------------------------------------------------
    # return

    return(percs)
}