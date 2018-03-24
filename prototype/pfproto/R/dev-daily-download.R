# Function to download and save data on all (current) dogs in DC. This will be
# run once a day via a cronjob, saving RDS files to the cache folder. These
# daily downloads will then be used to come up with the logic to determine
# which dogs are "new" as well as how to increment the "days on petfinder" count
dev_daily_download <- function() {
  dpet <- distinct_pet("washington, dc")

  maybe_gen_dir("cache")
  file <- file.path("cache", paste0(time_to_fstring(), ".rds"))

  saveRDS(dpet, file = file)
}
