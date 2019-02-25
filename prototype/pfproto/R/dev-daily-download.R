# Function to download and save data on all (current) dogs in DC. This will be
# run once a day via a cronjob, saving RDS files to the cache folder. These
# daily downloads will then be used to come up with the logic to determine
# which dogs are "new" as well as how to increment the "days on petfinder" count
dev_daily_download <- function() {
  
  dpet <- get_p_find(location = "washington, dc", count = 1000)
  
  if (httr::http_error(dpet)) {
    error <- httr::content(dpet, "text")
    send_gmail(body = error)
    df <- data.frame(time = time_to_fstring(), error = error)
    write.csv(df, "inst/cron/get-error.csv", row.names = FALSE)
  } else {
    maybe_gen_dir("cache")
    file <- file.path("cache", paste0(time_to_fstring(), ".rds"))
    saveRDS(dpet, file = file)
  }
}

cache_files <- function() {
  file <- list.files("cache", full.names = TRUE)
  tibble(
    file = file,
    date = lubridate::parse_date_time(gsub("[^[:digit:]-]", "", file), "ymdHMS")
  ) %>%
    arrange(date)
}

auth_gmail <- function(file = "/run/secrets/GMAIL") {
  gmailr::use_secret_file(file)
  gmailr::gmail_auth("compose")
}

send_gmail <- function(file, body) {
  auth_gmail(file)
  gmailr::mime(
    From = "pfanalytics787@gmail.com",
    To = "chriscrewbaker@gmail.com"
  ) %>% 
    gmailr::text_body(body) %>% 
    gmailr::send_message()
}