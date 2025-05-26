suppressPackageStartupMessages(
	{
        library(targets)
		library(tarchetypes)
        library(crew)
        library(gdata)
        library(docstring)
        library(stringr)
		library(dplyr)
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
    targets_pipeline_stats
)