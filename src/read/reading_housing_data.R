reading_housing_data <- function(
    data_file_path = NA
) {
    #' @title Reading housing data
    #' 
    #' @description This function reads housing data from a specified file path.
    #' 
    #' @param data_file_path String. The path to the data file.
    #' 
    #' @return Dataframe. The housing data read from the file.
    #' @author Patrick Thiel
    
    #--------------------------------------------------
    # read data

    dta <- haven::read_dta(data_file_path)

    #--------------------------------------------------
    # return

    return(dta)
}