helpers_target_names <- function() {
    #' @title Create target names
    #' 
    #' @description This function creates a list of target names used in the
    #' pipeline when dynamic branching is used (i.e. when tar_eval is used).
    #'  
    #' @return List, target names
    #' @author Patrick Thiel
    
    #--------------------------------------------------
    # list of target names

    ##### General names
    static_housing_types <- c("WK", "HK", "WM")

    target_names <- list(
        "static_housing_types" = static_housing_types,
        #--------------------------------------------------
        # preparation housing data
        "static_housing_data_org" = glue::glue(
            "{static_housing_types}_housing_data_org"
        ),
        "static_housing_data_cleaned" = glue::glue(
            "{static_housing_types}_housing_data_cleaned"
        ),
        #--------------------------------------------------
        # panel Campus Files
        "static_large_cities_sampled" = glue::glue(
            "{static_housing_types}_large_cities_sampled"
        ),
        "static_panel_sampled" = glue::glue(
            "{static_housing_types}_panel_sampled"
        ),
        #--------------------------------------------------
        # cross-section Campus Files
        "static_latest_year_sampled" = glue::glue(
            "{static_housing_types}_latest_year_sampled"
        )
    )

    #--------------------------------------------------
    # return

    return(target_names)
}