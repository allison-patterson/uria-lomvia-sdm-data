library(piggyback)

target_repo <- "allison-patterson/uria-lomvia-sdm-data"
target_tag  <- "v0.0.0"

file_inventory <- piggyback::pb_list(repo = my_repo, tag = "v0.0.0")

fn <- list.files('D:/tbmu-atlantic-sdm/data/ts_model/summaries', recursive = T, full.names = T)
fn <- fn[grep('2024', fn)]

flat <- paste0(
  gsub(',','',(gsub(' ','',basename(dirname(fn))))),
  '_',
  basename(fn)
)

idx <- !(flat %in% file_inventory$file_name)
fn <- fn[idx]
flat <- flat[idx]

# RUN LOOP WITH RETRY LOGIC
for (x in 1:length(fn)) {
  message("Uploading: ", fn[x])
  
  # Set up a retry loop (allows 3 attempts per file)
  success <- FALSE
  attempt <- 1
  
  while(!success && attempt <= 3) {
    tryCatch({
      piggyback::pb_upload(
        file = fn[x], 
        name = flat[x],
        repo = target_repo, # Explicitly pass the repo
        tag = target_tag,
        overwrite = FALSE 
      )
      success <- TRUE # If it gets here without failing, set success to TRUE
    }, error = function(e) {
      message("Attempt ", attempt, " failed on ", fn[x], " - Error: ", e$message)
      attempt <<- attempt + 1
      
      # Back off and wait longer if it fails (e.g., wait 15 seconds before trying again)
      Sys.sleep(15) 
    })
  }
  
  if (!success) {
    message("Permanently skipped: ", fn[x], " after 3 failed attempts.")
  }
  
  # Standard pause between successful files (increased slightly for safety)
  Sys.sleep(4)
}
