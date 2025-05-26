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

data_path <- "M:/_FDZ/RWI-GEO/RWI-GEO-RED/daten/CampusFile/"
version <- "v5"

last_year <- 2023

##############################
# Load data
##############################

# function
read_data <- function(type){
    data <- haven::read_dta(
        file.path(
        data_path, version, "cross_section/",
        paste0("CampusFile_", type, "_", last_year, ".dta")
        )
    )
    return(data)
}

# read in data
hk_cross <- read_data(type = "HK")
wk_cross <- read_data(type = "WK")
wm_cross <- read_data(type = "WM")

##############################
# Number of obs
##############################

# function to get obs
obs_function <- function(housingData){
    obs <- housingData |>
        group_by(gid2019) |>
        summarise(n = n()) |>
        as.data.frame()
    return(obs)
}

# get number of obs per municipality
obs_hk <- obs_function(hk_cross)
obs_wk <- obs_function(wk_cross)
obs_wm <- obs_function(wm_cross)

# merge
obs_aux <- merge(obs_hk, obs_wk, by = "gid2019", all = TRUE)
obs <- merge(obs_aux, obs_wm, by = "gid2019", all = TRUE)
colnames(obs) <- c("municipality", "house_sales", "apart_sales", "apart_rents")

# summarise obs by municipality into groups
thresholds <- c(0, 50, 200, 1000, 5000)

obs <- obs |> 
    mutate(
        NOBS_house_sales = case_when(
            house_sales >= thresholds[1] & house_sales <= thresholds[2] ~ "50",
            house_sales > thresholds[2] & house_sales <= thresholds[3] ~ "200",
            house_sales > thresholds[3] & house_sales <= thresholds[4] ~ "1000",
            house_sales > thresholds[4] & house_sales <= thresholds[5] ~ "5000",
            house_sales > thresholds[5] ~ "5000+"
        ),
        NOBS_apart_sales = case_when(
            apart_sales >= thresholds[1] & apart_sales <= thresholds[2] ~ "50",
            apart_sales > thresholds[2] & apart_sales <= thresholds[3] ~ "200",
            apart_sales > thresholds[3] & apart_sales <= thresholds[4] ~ "1000",
            apart_sales > thresholds[4] & apart_sales <= thresholds[5] ~ "5000",
            apart_sales > thresholds[5] ~ "5000+"
        ),
        NOBS_apart_rents = case_when(
            apart_rents >= thresholds[1] & apart_rents <= thresholds[2] ~ "50",
            apart_rents > thresholds[2] & apart_rents <= thresholds[3] ~ "200",
            apart_rents > thresholds[3] & apart_rents <= thresholds[4] ~ "1000",
            apart_rents > thresholds[4] & apart_rents <= thresholds[5] ~ "5000",
            apart_rents > thresholds[5] ~ "5000+"
        )
    )

# count groups
count_house_sales <- obs |>
    group_by(NOBS_house_sales) |>
    summarise(n = n()) |>
    as.data.frame()

count_apart_sales <- obs |>
    group_by(NOBS_apart_sales) |>
    summarise(n = n()) |>
    as.data.frame()

count_apart_rents <- obs |>
    group_by(NOBS_apart_rents) |>
    summarise(n = n()) |>
    as.data.frame()

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

# clean 
counts <- counts[c(3, 2, 1, 4, 5), ]
names(counts) <- c("category", "house_sales", "apart_sales", "apart_rents")

# export
write.xlsx(
    counts,
    file.path(
        data_path, version, "cross_section/number_municipalities_cross.xlsx"
    ),
    rowNames = FALSE
)

