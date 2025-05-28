sampling_large_cities <- function(
    housing_data = NA
) {
    #' @title Sampling for large cities
    #' 
    #' @description This function prepares the housing data for large cities
    #' by filtering the data for the largest cities in Germany.
    #' 
    #' @param housing_data Data frame, housing data to be prepared
    #' 
    #' @return Data frame, prepared housing data for large cities
    #' @author Patrick Thiel

    #--------------------------------------------------
    # subset for largest cities

    housing_data_prep <- housing_data |>
        dplyr::filter(
            kid2019 %in% config_globals()[["large_cities_kid2019"]] |
            gid2019 %in% config_globals()[["large_cities_gid2019"]]
        )

    #--------------------------------------------------
    # return

    return(housing_data_prep)
}