
# File  upload to github

my_repo <- "allison-patterson/uria-lomvia-sdm-data"

fn <- list.files('D:/tbmu-atlantic-sdm/data/ts_model/summaries', recursive = T, full.names = T)

#fn <- fn[grep('2024', fn)]

flat <- paste0(
  gsub(',','',(gsub(' ','',basename(dirname(fn))))),
  '_',
  basename(fn)
)
# for (x in 1:length(fn)) {
#   piggyback::pb_upload(file = fn[x], 
#                        name = flat[x], 
#                        repo = my_repo, 
#                        tag = "v0.0.0")
# }



for (x in 1:length(fn)) {
  message("Uploading: ", fn[x])
  
  # Wrap in a tryCatch so one failure doesn't ruin the whole multi-hour run
  tryCatch({
    piggyback::pb_upload(
      file = fn[x], 
      name = flat[x],
      tag = "v0.0.0",
      overwrite = FALSE 
    )
  }, error = function(e) {
    message("Failed on ", file, " - Error: ", e$message)
  })
  
  # CRUCIAL: Pause for 2 seconds to respect GitHub's API rate limits
  Sys.sleep(2)
}

# library(piggyback)
# 
# # 1. Fetch the master list of all files in your private release
# file_inventory <- piggyback::pb_list(repo = my_repo, tag = "v0.0.0")
# 
# r <- piggyback::pb_download(
#   file = file_inventory$file_name[1],
#   dest = ".",
#   repo = my_repo,
#   tag = "latest"
# )
