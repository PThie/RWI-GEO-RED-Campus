calculating_nobs_panel <- function(
    HK_data = NA,
    WK_data = NA,
    WM_data = NA
) {
    #' @title Calculate number of observations in panel data
    #'
    #' @description This function calculates the number of observations in the
    #' panel data for each housing type and returns a data frame with the
    #' results.
    #'
    #' @param HK_data Data frame containing the HK housing data.
    #' @param WK_data Data frame containing the WK housing data.
    #' @param WM_data Data frame containing the WM housing data.
    #'
    #' @return Data frame with the number of observations for each housing type.
    #' @author Patrick Thiel

    #--------------------------------------------------
    # define time horizon

    start_year <- 2007
    years <- config_globals()[["max_year_complete"]] - start_year

    #--------------------------------------------------
    # function to get number of obs for each city (rounded to nearest hundred)
    
    calculating_city_obs <- function(dataset, housing_type){
        varname <- paste0("obs_", housing_type)
        obs <- dataset |>
            dplyr::group_by(gid2019) |>
            dplyr::summarise(
                # {{varname}} := round(dplyr::n() / years, digits = -2)
                {{varname}} := dplyr::n()
            ) |>
            as.data.frame()
        return(obs)
    }

    #--------------------------------------------------
    # get city observations as year average

    nobs_HK <- calculating_city_obs(HK_data, housing_type = "HK")
    nobs_WK <- calculating_city_obs(WK_data, housing_type = "WK")
    nobs_WM <- calculating_city_obs(WM_data, housing_type = "WM")

    # merge together and assign city names
    obs_aux <- merge(nobs_HK, nobs_WK, by = "gid2019")
    obs <- merge(obs_aux, nobs_WM, by = "gid2019")

    #--------------------------------------------------
    # assign city names

    obs <- obs |>
        dplyr::mutate(
            city_name = dplyr::case_when(
                gid2019 == 2000000 ~ "Hamburg",
                gid2019 == 3241001 ~ "Hannover",
                gid2019 == 4011000 ~ "Bremen",
                gid2019 == 5111000 ~ "Düsseldorf",
                gid2019 == 5112000 ~ "Duisburg",
                gid2019 == 5113000 ~ "Essen",
                gid2019 == 5315000 ~ "Cologne",
                gid2019 == 5913000 ~ "Dortmund", 
                gid2019 == 6412000 ~ "Frankfurt",
                gid2019 == 8111000 ~ "Stuttgart",
                gid2019 == 9162000 ~ "Munich",
                gid2019 == 9564000 ~ "Nuremberg",
                gid2019 == 11000000 ~ "Berlin",
                gid2019 == 14612000 ~ "Dresden",
                gid2019 == 14713000 ~ "Leipzig"
            )
        )

    #--------------------------------------------------
    # select and sort

    obs <- obs |>
        dplyr::select(gid2019, city_name, obs_HK, obs_WK, obs_WM) |>
        dplyr::arrange(city_name)

    #--------------------------------------------------
    # export

    openxlsx::write.xlsx(
        obs,
        file.path(
            config_paths()[["output_path"]],
            config_globals()[["next_version"]],
            "number_of_observations_panel.xlsx"
        ),
        rowNames = FALSE
    )

    # export to latex (for reporting)
    obs |>
        kableExtra::kbl(
            escape = FALSE,
            format = "latex",
            longtable = TRUE,
            align = "l",
            linesep = "",
            caption = "Approx. number of observations per city per year in the Panel Cmapus File",
            col.names = c(
                "AGS",
                "City",
                "\\makecell[l]{Houses for\\\\sale}",
                "\\makecell[l]{Apartment for\\\\sale}",
                "\\makecell[l]{Apartment for\\\\rent}"
            ),
            label = "observations_per_city"
        ) |>
        kableExtra::kable_styling(
            latex_options = c(
                "striped",
                "hold_position"
            ),
            # NOTE: color is defined in report latex file
            # see coding: \definecolor{user_gray}{rgb}{0.851,0.851,0.851}
            stripe_color = "user_gray"
        ) |>
        kableExtra::save_kable(
            file.path(
                config_paths()[["output_path"]],
                config_globals()[["next_version"]],
                "number_of_observations_panel.tex"
            ),
            label = "tab:observations_per_city"
        )

    #--------------------------------------------------
    # return

    return(obs)
}