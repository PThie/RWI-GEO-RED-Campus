sampling_latest_year <- function(
    housing_data = NA
) {
    #' @title Prepare housing data for latest year
    #' 
    #' @description This function prepares the housing data for the latest year
    #' by filtering the data for the last complete year and keeping only the
    #' latest spell of each advertisement.
    #' 
    #' @param housing_data Data frame, housing data to be prepared
    #' 
    #' @return Data frame, prepared housing data for latest year
    #' @author Patrick Thiel
    
    #--------------------------------------------------
    # keep only the last complete year in the data

    housing_data_prep <- housing_data |>
        dplyr::filter(
            ajahr == config_globals()[["max_year_complete"]] |
            ejahr == config_globals()[["max_year_complete"]] |
            (ajahr < config_globals()[["max_year_complete"]] & ejahr == config_globals()[["max_year"]])
        )

    # test that only 12 months are in the data
    for (dates in c("edat", "adat")) {
        targets::tar_assert_true(
            length(unique(housing_data_prep[[dates]])) == 12,
            msg = glue::glue(
                "There are not exactly 12 months in the data for {dates}.",
                " (Error code: sly#1)"
            )
        )
    }

    #--------------------------------------------------
    # keep only the latest spell of each advertisement

    housing_data_prep <- housing_data_prep |>
        dplyr::group_by(obid) |>
        dplyr::filter(spell == max(spell, na.rm = TRUE)) |>
        dplyr::ungroup() |>
        dplyr::select(-c(
            "spell",
            "ajahr",
            "ejahr",
            "amonat", 
            "emonat"
        ))

    #--------------------------------------------------
    # return

    return(housing_data_prep)
}