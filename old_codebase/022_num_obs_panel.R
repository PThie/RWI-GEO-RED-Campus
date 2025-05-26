##############################
# Description
##############################

# calculate the average number of observation for each city in the 
# Panel Campus File

##############################
# load libraries
##############################

library(dplyr)
library(openxlsx)

##############################
# Paths
##############################

dataPath <- "M:/_FDZ/RWI-GEO/RWI-GEO-RED/daten/CampusFile/"
version <- "v5"

##############################
# Load data
##############################

# function
read_data <- function(type){
    data <- haven::read_dta(
        file.path(
        dataPath, version, "panel/", paste0("CampusFile_", type, "_cities.dta")
        )
    )
    return(data)
}

# read in data
hk_panel <- read_data(type = "HK")
wk_panel <- read_data(type = "WK")
wm_panel <- read_data(type = "WM")

##############################
# Number of obs
##############################
# average over years and for each city

# time horizon
start_year = 2007
end_year = 2023
years = end_year - start_year

# function to get number of obs for each city (rounded to nearest hundred)
city_obs <- function(dataset, type){
    varname <- paste0("obs_", type)
    obs <- dataset |>
        group_by(gid2019) |>
        summarise(
            {{varname}} := round(n()/years, digits = -2)
        ) |>
        as.data.frame()
    return(obs)
}

# get city observations as year average
obsHK <- city_obs(hk_panel, type = "HK")
obsWK <- city_obs(wk_panel, type = "WK")
obsWM <- city_obs(wm_panel, type = "WM")

# merge together and assign city names
obs_aux <- merge(obsHK, obsWK, by = "gid2019")
obs <- merge(obs_aux, obsWM, by = "gid2019")

obs <- obs |> mutate(
    city_name = case_when(
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

# sort
obs <- obs |> select(gid2019, city_name, obs_HK, obs_WK, obs_WM)
obs <- obs[order(obs$city_name), ]

##############################
# Export
##############################

write.xlsx(
    obs,
    file.path(
        data_path,
        version,
        "panel/number_observations_panel.xlsx"
    ),
    rowNames = FALSE
)
