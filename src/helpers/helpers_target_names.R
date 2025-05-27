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
        "static_housing_data_org" = glue::glue(
            "{static_housing_types}_housing_data_org"
        ),
        "static_housing_data_cleaned" = glue::glue(
            "{static_housing_types}_housing_data_cleaned"
        )
    )

    #--------------------------------------------------
    # return

    return(target_names)
}