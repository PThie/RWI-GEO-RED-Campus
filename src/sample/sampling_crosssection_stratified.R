sampling_crosssection_stratified <- function(
    housing_data = NA,
    housing_type = NA
) {
    #' @title Sampling cross-section Campus Files
    #' 
    #' @description This function prepares the housing data for a cross-section
    #' Campus File by stratifying the sample based on the number of observations
    #' in each municipality and district.
    #' 
    #' @param housing_data Data frame, housing data to be prepared
    #' @param housing_type Character, type of housing (e.g. "WK", "HK", "WM")
    #' 
    #' @return Data frame, prepared housing data for cross-section Campus File
    #' @author Patrick Thiel
    
    #--------------------------------------------------
    # create sampling variables

    if (housing_type %in% c("HK", "WK")) {
        housing_data_sampled <- housing_data |>
            #  Step 1: generate random number within gid2019
            dplyr::group_by(gid2019) |>
            dplyr::mutate(
                random = runif(dplyr::n())
            ) |>
            dplyr::ungroup() |>
            # Step 2: count observations per gid2019
            dplyr::group_by(gid2019) |>
            dplyr::mutate(
                NOBS_munic = dplyr::n()
            ) |>
            dplyr::ungroup() |>
            # censor municipality if less than 50 observations (anonymized due to data protection)
            # censor NOBS if less than 50 observations
            dplyr::mutate(
                gid2019 = dplyr::case_when(
                    NOBS_munic < 50 ~ NA,
                    TRUE ~ gid2019
                ),
                NOBS_munic = dplyr::case_when(
                    NOBS_munic < 50 ~ NA,
                    TRUE ~ NOBS_munic
                )
            ) |>
            # Step 3: count observations per kid2019
            dplyr::group_by(kid2019) |>
            dplyr::mutate(
                NOBS_district = dplyr::n()
            ) |>
            dplyr::ungroup()
    } else {
        # NOTE: WM uses a different sampling strategy because there are a lot
        # of rent obervations in the data
        housing_data_sampled <- housing_data |>
            dplyr::group_by(gid2019) |>
            dplyr::mutate(
                random = runif(dplyr::n()),
                NOBS_munic = dplyr::n()
            ) |>
            dplyr::ungroup()
    }

    #--------------------------------------------------
    # drop cases if too few observations

    if (housing_type == "WK") {
        # keep only counties with at least 100 observations
        housing_data_sampled <- housing_data_sampled |>
            dplyr::filter(NOBS_district >= 100)
    }

    if (housing_type == "WM") {
        housing_data_sampled <- housing_data_sampled |>
            dplyr::filter(NOBS_munic >= 50)
    }

    #--------------------------------------------------
    # Step 4: decide if observation is in sample

    if (housing_type %in% c("HK", "WK")) {
        housing_data_sampled <- housing_data_sampled |>
            dplyr::mutate(
                insample = dplyr::case_when(
                    NOBS_munic <= 200 ~ 50 / NOBS_munic <= random,
                    NOBS_munic > 200 & NOBS_munic <= 1000 ~ 200 / NOBS_munic <= random,
                    NOBS_munic > 1000 & NOBS_munic <= 5000 ~ 1000 / NOBS_munic <= random,
                    NOBS_munic > 5000 ~ 5000 / NOBS_munic <= random,
                    is.na(NOBS_munic) ~ 100 / NOBS_district <= random
                )
            )
    } else {
        housing_data_sample <- housing_data_sampled |>
            dplyr::mutate(
                insample = dplyr::case_when(
                    NOBS_munic <= 200 ~ 50 / NOBS_munic <= random,
                    NOBS_munic > 200 & NOBS_munic <= 1000 ~ 200 / NOBS_munic <= random,
                    NOBS_munic > 1000 & NOBS_munic <= 5000 ~ 1000 / NOBS_munic <= random,
                    NOBS_munic > 5000 ~ 5000 / NOBS_munic <= random
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
            "NOBS_munic",
            "NOBS_district",
            "random"
        ))

    #--------------------------------------------------
    # export

    data.table::fwrite(
        housing_data_sampled,
        file.path(
            config_paths()[["data_path"]],
            config_globals()[["next_version"]],
            "cross_section",
            paste0(
                "CampusFile_",
                housing_type,
                "_",
                config_globals()[["maxyear_complete"]],
                ".csv"
            )
        )
    )

    #--------------------------------------------------
    # return

    return(housing_data_sampled)
}
