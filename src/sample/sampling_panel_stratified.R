sampling_panel_stratified <- function(
    housing_data = NA,
    housing_type = NA
) {
    #' @title Sampling for panel dataset stratified
    #' 
    #' @description This function prepares the housing data for a panel dataset
    #' by filtering the data for the largest cities in Germany and stratifying
    #' the sample by housing type.
    #' 
    #' @param housing_data Data frame, housing data to be prepared
    #' @param housing_type Character, type of housing (e.g. "WK", "HK", "WM")
    #' 
    #' @return Data frame, prepared housing data for panel dataset
    #' @author Patrick Thiel

    #--------------------------------------------------
    # ensure that only complete years are used

    if (config_globals()[["max_year"]] != config_globals()[["max_year_complete"]]) {
        housing_data <- housing_data |>
            dplyr::filter(ajahr != config_globals()[["max_year"]])
    }

    #--------------------------------------------------
    # in case end date lies in the future, set to last complete year
    
    housing_data <- housing_data |>
        dplyr::mutate(
            edat = dplyr::case_when(
                edat > paste0(config_globals()[["max_year_complete"]], "-12") ~ paste0(config_globals()[["max_year_complete"]], "-12"),
                TRUE ~ edat
            ),
            ejahr = dplyr::case_when(
                ejahr == config_globals()[["max_year"]] ~ config_globals()[["max_year_complete"]],
                TRUE ~ ejahr
            )
        )

    #--------------------------------------------------
    # stratified sampling

    housing_data_sampled <- housing_data |>
        # Step 1: count observations per year and kid2019
        dplyr::group_by(ejahr, kid2019) |>
        dplyr::mutate(
            NOBS = dplyr::n()
        ) |>
        dplyr::ungroup() |>
        # Step 2: generate random number within year and gid2019
        dplyr::group_by(ejahr, gid2019) |>
        dplyr::mutate(
            random = runif(dplyr::n())
        ) |>
        dplyr::ungroup() |>
        # Step 3: find minimum number of observations per kid2019
        dplyr::group_by(kid2019) |>
        dplyr::mutate(
            NOBS_min = min(NOBS, na.rm = TRUE)
        ) |>
        dplyr::ungroup() |>
        as.data.frame()

    #--------------------------------------------------
    # Step 4: decide if observation is in sample

    if (housing_type == "HK") {
        housing_data_sampled <- housing_data_sampled |>
            dplyr::mutate(
                insample = dplyr::case_when(
                    NOBS_min <= 2000 ~ 1000 / NOBS <= random,
                    NOBS_min > 2000 & NOBS_min < 5000 ~ 2000 / NOBS <= random,
                    NOBS_min >= 5000 ~ 5000 / NOBS <= random
                )
            )
    } else if (housing_type == "WK") {
        housing_data_sampled <- housing_data_sampled |>
            dplyr::mutate(
                insample = dplyr::case_when(
                    NOBS_min <= 4000 ~ 2000 / NOBS <= random,
                    NOBS_min > 4000 & NOBS_min < 10000 ~ 4000 / NOBS <= random,
                    NOBS_min >= 10000 ~ 10000 / NOBS <= random
                )
            )
    } else {
        housing_data_sampled <- housing_data_sampled |>
            dplyr::mutate(
                insample = dplyr::case_when(
                    NOBS_min <= 15000 ~ 7000 / NOBS <= random,
                    NOBS_min > 15000 & NOBS_min <= 40000 ~ 15000 / NOBS <= random,
                    NOBS_min > 40000 & NOBS_min <= 50000 ~ 40000 / NOBS <= random,
                    NOBS_min > 50000 ~ 50000 / NOBS <= random
                )
            )
    }

    #--------------------------------------------------
    # keep observations that satisfy random < threshold

    housing_data_sampled <- housing_data_sampled |>
        dplyr::filter(insample == FALSE)

    #--------------------------------------------------
    # remove helper variables

    housing_data_sampled <- housing_data_sampled |>
        dplyr::select(-c(
            "insample", 
            "NOBS",
            "NOBS_min",
            "random",
            "ejahr",
            "emonat",
            "ajahr",
            "amonat"
        ))

    #--------------------------------------------------
    # export

    data.table::fwrite(
        housing_data_sampled,
        file.path(
            config_paths()[["data_path"]],
            config_globals()[["next_version"]],
            "panel",
            paste0(
                "CampusFile_",
                housing_type,
                "_cities.csv"
            )
        )
    )

    #--------------------------------------------------
    # return

    return(housing_data_sampled)
}

