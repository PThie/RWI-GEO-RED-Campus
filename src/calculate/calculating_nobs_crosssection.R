calculating_nobs_crosssection <- function(
    HK_data = NA,
    WK_data = NA,
    WM_data = NA
) {
    #' @title Calculate number of observations in cross-section
    #'
    #' @description This function calculates the number of observations in the
    #' cross-section for each municipality and housing type.
    #'
    #' @param HK_data Data frame with housing data for house sales.
    #' @param WK_data Data frame with housing data for apartment sales.
    #' @param WM_data Data frame with housing data for apartment rents.
    #'
    #' @return Data frame with the number of observations per municipality and
    #' housing type.
    #' @author Patrick Thiel

    #--------------------------------------------------
    # function to calculate number of observations by municipality

    calculating_city_obs <- function(housing_data = NA){
        obs <- housing_data |>
            dplyr::group_by(gid2019) |>
            dplyr::summarise(n = dplyr::n()) |>
            as.data.frame()
        return(obs)
    }

    #--------------------------------------------------
    # get number of obs per municipality

    nobs_HK <- calculating_city_obs(HK_data)
    nobs_WK <- calculating_city_obs(WK_data)
    nobs_WM <- calculating_city_obs(WM_data)

    #--------------------------------------------------
    # merge all together

    nobs_aux <- merge(
        nobs_HK,
        nobs_WK,
        by = "gid2019",
        all = TRUE
    )

    nobs <- merge(
        nobs_aux,
        nobs_WM,
        by = "gid2019",
        all = TRUE
    )
    
    colnames(nobs) <- c(
        "municipality",
        "house_sales",
        "apart_sales",
        "apart_rents"
    )

    #--------------------------------------------------
    # summarise obs by municipality into groups

    thresholds <- c(0, 50, 200, 1000, 5000)

    nobs <- nobs |> 
        dplyr::mutate(
            NOBS_house_sales = dplyr::case_when(
                house_sales >= thresholds[1] & house_sales <= thresholds[2] ~ "50",
                house_sales > thresholds[2] & house_sales <= thresholds[3] ~ "200",
                house_sales > thresholds[3] & house_sales <= thresholds[4] ~ "1000",
                house_sales > thresholds[4] & house_sales <= thresholds[5] ~ "5000",
                house_sales > thresholds[5] ~ "5000+"
            ),
            NOBS_apart_sales = dplyr::case_when(
                apart_sales >= thresholds[1] & apart_sales <= thresholds[2] ~ "50",
                apart_sales > thresholds[2] & apart_sales <= thresholds[3] ~ "200",
                apart_sales > thresholds[3] & apart_sales <= thresholds[4] ~ "1000",
                apart_sales > thresholds[4] & apart_sales <= thresholds[5] ~ "5000",
                apart_sales > thresholds[5] ~ "5000+"
            ),
            NOBS_apart_rents = dplyr::case_when(
                apart_rents >= thresholds[1] & apart_rents <= thresholds[2] ~ "50",
                apart_rents > thresholds[2] & apart_rents <= thresholds[3] ~ "200",
                apart_rents > thresholds[3] & apart_rents <= thresholds[4] ~ "1000",
                apart_rents > thresholds[4] & apart_rents <= thresholds[5] ~ "5000",
                apart_rents > thresholds[5] ~ "5000+"
            )
        )

    #--------------------------------------------------
    # count groups

    counting_groups <- function(var) {
        count_groups <- nobs |>
            dplyr::group_by(.data[[var]]) |>
            dplyr::summarise(n = dplyr::n()) |>
            as.data.frame()
        return(count_groups)
    }

    count_house_sales <- counting_groups("NOBS_house_sales")
    count_apart_sales <- counting_groups("NOBS_apart_sales")
    count_apart_rents <- counting_groups("NOBS_apart_rents")

    counts_aux <- merge(
        count_house_sales,
        count_apart_sales,
        by.x = "NOBS_house_sales",
        by.y = "NOBS_apart_sales"
    )

    counts <- merge(
        counts_aux,
        count_apart_rents,
        by.x = "NOBS_house_sales",
        by.y = "NOBS_apart_rents"
    )

    #--------------------------------------------------
    # cleaning

    counts <- counts[c(3, 2, 1, 4, 5), ]
    names(counts) <- c(
        "category", "house_sales",
        "apart_sales", "apart_rents"
    )

    #--------------------------------------------------
    # add total count

    total_counts <- cbind(
        category = "All municipalities",
        counts |>
            dplyr::summarise(
                dplyr::across(
                    .cols = dplyr::contains("_"),
                    ~ sum(.x, na.rm = TRUE)
                )
            )
    )

    counts <- rbind(counts, total_counts)

    #--------------------------------------------------
    # export

    openxlsx::write.xlsx(
        counts,
        file.path(
            config_paths()[["output_path"]],
            config_globals()[["next_version"]],
            "number_of_observations_crosssection.xlsx"
        ),
        rowNames = FALSE
    )

    # export to latex (for reporting)
    counts |>
        kableExtra::kbl(
            escape = FALSE,
            format = "latex",
            longtable = TRUE,
            align = "l",
            linesep = "",
            caption = "Number of municipalities in the cross-section Campus File",
            col.names = c(
                "NOBS",
                "\\makecell[l]{Houses for\\\\sale}",
                "\\makecell[l]{Apartment for\\\\sale}",
                "\\makecell[l]{Apartment for\\\\rent}"
            ),
            label = "municipalities"
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
                "number_of_observations_crosssection.tex"
            ),
            label = "tab:municipalities"
        )

    #--------------------------------------------------
    # return

    return(counts)
}