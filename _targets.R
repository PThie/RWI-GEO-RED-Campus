suppressPackageStartupMessages(
	{
        library(targets)
		library(tarchetypes)
        library(crew)
        library(gdata)
        library(docstring)
        library(stringr)
		library(dplyr)
		library(glue)
		library(data.table)
		library(openxlsx)
		library(kableExtra)
	}
)

#----------------------------------------------
# load configurations

source(
    file.path(
        here::here(),
        "src",
        "helpers",
        "config.R"
    )
)

#--------------------------------------------------
# Pipeline settings

# target options
controller <- crew_controller_local(
    name = "worker",
    workers = 3,
    seconds_idle = 10,
    options_metrics = crew_options_metrics(
        path = file.path(
            config_paths()[["logs_path"]],
            "worker_metrics",
            "worker_metrics_history"
        ),
        seconds_interval = 1
    )
)

tar_option_set(
    resources = tar_resources(
        fst = tar_resources_fst(compress = 100)
    ),
    seed = 1,
    garbage_collection = TRUE,
    memory = "transient",
    controller = controller,
    retrieval = "worker",
    storage = "worker"
)

#--------------------------------------------------
# load R scripts

sub_directories <- list.dirs(
    config_paths()[["src_path"]],
    full.names = FALSE,
    recursive = FALSE
)

for (sub_directory in sub_directories) {
	if (!sub_directory %in% c("archive", "plot", "make")) {
		if (sub_directory != "helpers") { 
			lapply(
				list.files(
					file.path(
						config_paths()[["src_path"]],
						sub_directory
					),
					pattern = "\\.R$",
					full.names = TRUE,
					ignore.case = TRUE
				),
				source
			)
		} else {
			files <- list.files(
				file.path(
					config_paths()[["src_path"]],
					sub_directory
				),
				pattern = "\\.R$",
				full.names = TRUE,
				ignore.case = TRUE
			)
			files <- files[
				stringr::str_detect(
					files,
					"config.R$"
				) == FALSE
			]
			lapply(files, source)
		}
	}
}

###################################################
# ACTUAL PIPELINE
###################################################

#--------------------------------------------------
# Folder generation

targets_preparation_folders <- rlang::list2(
    tar_target(
        empty_folders,
        creating_folder_structure()
    )
)

#--------------------------------------------------
# reading and preparation housing data

targets_housing_data <- rlang::list2(
	tar_eval(
		list(
			tar_file_read(
				housing_data,
				file.path(
					config_paths()[["red_data_path"]],
					paste0(
						housing_types,
						"_SUF_ohneText.dta"
					)
				),
				reading_housing_data(!!.x),
				format = "fst"
			),
			tar_fst(
				housing_data_cleaned,
				cleaning_housing_data(
					housing_type = housing_types,
					housing_data = housing_data
				)
			),
			#--------------------------------------------------
			# Creating panel Campus Files
			tar_fst(
				large_cities_sampled,
				sampling_large_cities(
					housing_data = housing_data_cleaned
				)
			),
			tar_fst(
				panel_sampled,
				sampling_panel_stratified(
					housing_type = housing_types,
					housing_data = large_cities_sampled
				)
			),
			#--------------------------------------------------
			# Creating cross-section Campus Files
			tar_fst(
				latest_year_sampled,
				sampling_latest_year(
					housing_data = housing_data_cleaned
				)
			),
			tar_fst(
				cross_section_sampled,
				sampling_crosssection_stratified(
					housing_type = housing_types,
					housing_data = latest_year_sampled
				)
			)
		),
		values = list(
			housing_types = helpers_target_names()[["static_housing_types"]],
			housing_data = rlang::syms(helpers_target_names()[["static_housing_data_org"]]),
			housing_data_cleaned = rlang::syms(helpers_target_names()[["static_housing_data_cleaned"]]),
			large_cities_sampled = rlang::syms(helpers_target_names()[["static_large_cities_sampled"]]),
			panel_sampled = rlang::syms(helpers_target_names()[["static_panel_sampled"]]),
			latest_year_sampled = rlang::syms(helpers_target_names()[["static_latest_year_sampled"]]),
			cross_section_sampled = rlang::syms(helpers_target_names()[["static_cross_section_sampled"]])
		)
	)
)

#--------------------------------------------------
# descriptives

targets_descriptives <- rlang::list2(
	tar_fst(
		panel_NOBS,
		calculating_nobs_panel(
			HK_data = HK_panel_sampled,
			WK_data = WK_panel_sampled,
			WM_data = WM_panel_sampled
		)
	),
	tar_fst(
		cross_section_NOBS,
		calculating_nobs_crosssection(
			HK_data = HK_cross_section_sampled,
			WK_data = WK_cross_section_sampled,
			WM_data = WM_cross_section_sampled
		)
	)
)

#--------------------------------------------------
# pipeline stats

targets_pipeline_stats <- rlang::list2(
	tar_file(
		pipeline_stats,
		helpers_monitoring_pipeline(),
		cue = tar_cue(mode = "always")
	),
    tar_target(
        worker_stats,
        reading_worker_stats(),
        cue = tar_cue(mode = "always")
    )
)

#----------------------------------------------
# all together

rlang::list2(
	targets_preparation_folders,
	targets_housing_data,
	targets_descriptives,
    targets_pipeline_stats
)