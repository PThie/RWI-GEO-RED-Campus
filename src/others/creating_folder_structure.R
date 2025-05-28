creating_folder_structure <- function() {
    #' @title Create folder structure
    #' 
    #' @description This function creates the folder structure for the output
    #' of a new wave.
    #' 
    #' @return NULL
    #' @author Patrick Thiel
    
    #--------------------------------------------------

    ifelse(
        !dir.exists(
            file.path(
                config_paths()[["data_path"]],
                config_globals()[["next_version"]]
            )
        ),
        yes = dir.create(
            file.path(
                config_paths()[["data_path"]],
                config_globals()[["next_version"]]
            )
        ),
        no = cli::cli_alert_success(
            cli::col_green(
                "Version directory for data folder already exists."    
            )
        )
    )
    
    #----------------------------------------------
    # folder generation for new delivery (in data folder)

    for (data_folder in config_globals()[["data_folders"]]) {
        ifelse(
                !dir.exists(
                    file.path(
                        config_paths()[["data_path"]],
                        config_globals()[["next_version"]],
                        data_folder
                    )
                ),
                yes = dir.create(
                    file.path(
                        config_paths()[["data_path"]],
                        config_globals()[["next_version"]],
                        data_folder
                    )
                ),
                no = cli::cli_alert_success(
                    cli::col_green(
                        "Version directory for \"{data_folder}\" data folder already exists."    
                    )
                )
        )
    }

    #--------------------------------------------------
    # folder generation for new delivery (output folder)
    
    ifelse(
        !dir.exists(
            file.path(
                config_paths()[["output_path"]],
                config_globals()[["next_version"]]
            )
        ),
        yes = dir.create(
            file.path(
                config_paths()[["output_path"]],
                config_globals()[["next_version"]]
            )
        ),
        no = cli::cli_alert_success(
            cli::col_green(
                "Version directory for output folder already exists."    
            )
        )
    )

    #--------------------------------------------------
    # return

    return(NULL)
}