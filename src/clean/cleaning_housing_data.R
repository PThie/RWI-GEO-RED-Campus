cleaning_housing_data <- function(
    housing_type = NA,
    housing_data = NA
) {
    #' @title Cleaning housing data
    #' 
    #' @description This function cleans the housing data for the given
    #' housing type.
    #' 
    #' @param housing_type Character, type of housing data to clean.
    #' @param housing_data Data frame, housing data to clean.
    #' 
    #' @return Data frame, cleaned housing data.
    #' @author Patrick Thiel

    #--------------------------------------------------
    # remove performance variables
    
    perf_vars <- c(
        "hits",
        "hits_gen",
        "click_schnellkontakte",
        "click_schnellkontakte_gen",
        "click_customer",
        "click_weitersagen",
        "click_weitersagen_gen",
        "click_url",
        "click_url_gen",
        "liste_show",
        "liste_show_gen",
        "liste_match",
        "liste_match_gen"
    )

    # check if variables are in the data
    for (var in perf_vars) {
        targets::tar_assert_true(
            var %in% names(housing_data),
            msg = glue::glue(
                "Variable '{var}' not found in housing data for type '{housing_type}'.",
                " (Error code: chd#1)"
            )
        )
    }

    housing_data_prep <- housing_data |>
        dplyr::select(-dplyr::all_of(perf_vars))

    #--------------------------------------------------
    # remove variables independent of type

    delete_vars <- c(
        "mietewarm",
        "gid2015",
        "kid2015",
        "uniqueID_gen",
        "dupID_gen",
        "kid_updated",
        "gid_updated",
        "duplicateid",
        "erg_amd",
        "betreut",
        "lieferung"
    )

    # check if variables are in the data
    for (var in delete_vars) {
        targets::tar_assert_true(
            var %in% names(housing_data_prep),
            msg = glue::glue(
                "Variable '{var}' not found in housing data for type '{housing_type}'.",
                " (Error code: chd#2)"
            )
        )
    }

    housing_data_prep <- housing_data_prep |>
        dplyr::select(-dplyr::all_of(delete_vars))

    #--------------------------------------------------
    # create dates

    housing_data_prep <- housing_data_prep |>
        dplyr::mutate(
            adat = paste0(ajahr, "-", amonat),
            edat = paste0(ejahr, "-", emonat)
        )

    #--------------------------------------------------
    # handle construction year

    housing_data_prep <- housing_data_prep |>
        dplyr::mutate(
            baujahr = dplyr::case_when(
                baujahr < 1500 ~ NA_real_, # unrealistic
                TRUE ~ baujahr
            )
        ) |>
        # remove properties built in the future
        dplyr::filter(
            baujahr <= config_globals()[["max_year"]]
        )

    #--------------------------------------------------
    # handle living area

    # remove top and bottom percentile
    housing_data_prep <- housing_data_prep |>
        merge(
            helpers_combining_percentile_calculations(
                housing_data = housing_data_prep,
                var_of_interest = "wohnflaeche",
                top_perc = 0.99,
                bottom_perc = 0.01
            ),
            by = "ejahr",
            all.x = TRUE
        )
    
    housing_data_prep <- housing_data_prep |>
        dplyr::filter(
            wohnflaeche > percentile_value_bottom &
            wohnflaeche <= percentile_value_top
        ) |>
        dplyr::select(-dplyr::starts_with("percentile"))

    #--------------------------------------------------
    # cleaning steps specific to sales (HK, WK)

    if (housing_type %in% c("HK", "WK")) {
        #--------------------------------------------------
        # clean dependent variable (price)

        # drop missing prices and living area
        housing_data_prep <- housing_data_prep |>
            dplyr::filter(
                kaufpreis > 0
            ) |>
            dplyr::filter(
                wohnflaeche > 0
            )

        # remove top and bottom percentile
        housing_data_prep <- housing_data_prep |>
            merge(
                helpers_combining_percentile_calculations(
                    housing_data = housing_data_prep,
                    var_of_interest = "kaufpreis",
                    top_perc = 0.99,
                    bottom_perc = 0.01
                ),
                by = "ejahr",
                all.x = TRUE
            )

        housing_data_prep <- housing_data_prep |>
            dplyr::filter(
                kaufpreis > percentile_value_bottom &
                kaufpreis <= percentile_value_top
            ) |>
            dplyr::select(-dplyr::starts_with("percentile"))

        #--------------------------------------------------
        # handle price per square meter

        # create price per square meter
        housing_data_prep <- housing_data_prep |>
            dplyr::mutate(
                price_sqm = kaufpreis / wohnflaeche,
                price_sqm = dplyr::case_when(
                    price_sqm < 0 ~ NA_real_,
                    TRUE ~ price_sqm
                )
            )

        # remove top and bottom percentile
        housing_data_prep <- housing_data_prep |>
            merge(
                helpers_combining_percentile_calculations(
                    housing_data = housing_data_prep,
                    var_of_interest = "price_sqm",
                    top_perc = 0.99,
                    bottom_perc = 0.01
                ),
                by = "ejahr",
                all.x = TRUE
            )
        
        housing_data_prep <- housing_data_prep |>
            dplyr::filter(
                price_sqm > percentile_value_bottom &
                price_sqm <= percentile_value_top
            ) |>
            dplyr::select(-dplyr::starts_with("percentile"))
    } else {
        #--------------------------------------------------
        # clean dependent variable (rent)

        # drop missing rent and living area
        housing_data_prep <- housing_data_prep |>
            dplyr::filter(
                mietekalt > 0
            ) |>
            dplyr::filter(
                wohnflaeche > 0
            )

        # remove top and bottom percentile
        housing_data_prep <- housing_data_prep |>
            merge(
                helpers_combining_percentile_calculations(
                    housing_data = housing_data_prep,
                    var_of_interest = "mietekalt",
                    top_perc = 0.99,
                    bottom_perc = 0.01
                ),
                by = "ejahr",
                all.x = TRUE
            )

        housing_data_prep <- housing_data_prep |>
            dplyr::filter(
                mietekalt > percentile_value_bottom &
                mietekalt <= percentile_value_top
            ) |>
            dplyr::select(-dplyr::starts_with("percentile"))

        #--------------------------------------------------
        # handle rent per square meter

        # create price per square meter
        housing_data_prep <- housing_data_prep |>
            dplyr::mutate(
                rent_sqm = mietekalt / wohnflaeche,
                rent_sqm = dplyr::case_when(
                    rent_sqm < 0 ~ NA_real_,
                    TRUE ~ rent_sqm
                )
            )

        # remove top and bottom percentile
        housing_data_prep <- housing_data_prep |>
            merge(
                helpers_combining_percentile_calculations(
                    housing_data = housing_data_prep,
                    var_of_interest = "rent_sqm",
                    top_perc = 0.99,
                    bottom_perc = 0.01
                ),
                by = "ejahr",
                all.x = TRUE
            )
        
        housing_data_prep <- housing_data_prep |>
            dplyr::filter(
                rent_sqm > percentile_value_bottom &
                rent_sqm <= percentile_value_top
            ) |>
            dplyr::select(-dplyr::starts_with("percentile"))
    }

    #--------------------------------------------------
    # cleaning steps specific to types

    if (housing_type == "HK") {
        #--------------------------------------------------
        # remove not needed variables

        delete_vars <- c(
            "mietekalt",
            "nebenkosten",
            "anzahletagen",
            "etage",
            "wohngeld",
            "aufzug",
            "balkon",
            "heizkosten_in_wm_enthalten",
            "kategorie_Wohnung"
        )

        # check if variables are in the data
        for (var in delete_vars) {
            targets::tar_assert_true(
                var %in% names(housing_data_prep),
                msg = glue::glue(
                    "Variable '{var}' not found in housing data for type '{housing_type}'.",
                    " (Error code: chd#3)"
                )
            )
        }

        housing_data_prep <- housing_data_prep |>
            dplyr::select(-dplyr::all_of(delete_vars))

    } else if (housing_type == "WK") {
        #--------------------------------------------------
        # remove not needed variables

        delete_vars <- c(
            "mietekalt",
            "nebenkosten",
            "heizkosten_in_wm_enthalten",
            "kategorie_Haus",
            "mieteinnahmenpromonat",
            "ferienhaus",
            "foerderung",
            "kaufvermietet"
        )

        # check if variables are in the data
        for (var in delete_vars) {
            targets::tar_assert_true(
                var %in% names(housing_data_prep),
                msg = glue::glue(
                    "Variable '{var}' not found in housing data for type '{housing_type}'.",
                    " (Error code: chd#4)"
                )
            )
        }

        housing_data_prep <- housing_data_prep |>
            dplyr::select(-dplyr::all_of(delete_vars))
    } else {
        #--------------------------------------------------
        # remove not needed variables

        delete_vars <- c(
            "kaufpreis",
            "mieteinnahmenpromonat",
            "grundstuecksflaeche",
            "parkplatzpreis",
            "wohngeld",
            "denkmalobjekt",
            "einliegerwohnung",
            "ferienhaus",
            "kaufvermietet",
            "kategorie_Haus"
        )

        # check if variables are in the data
        for (var in delete_vars) {
            targets::tar_assert_true(
                var %in% names(housing_data_prep),
                msg = glue::glue(
                    "Variable '{var}' not found in housing data for type '{housing_type}'.",
                    " (Error code: chd#5)"
                )
            )
        }

        housing_data_prep <- housing_data_prep |>
            dplyr::select(-dplyr::all_of(delete_vars))
    }

    #--------------------------------------------------
    # return

    return(NULL)
}
