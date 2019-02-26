# Function to download and save data on all (current) dogs in DC. This will be
# run once a day via a cronjob, saving RDS files to the cache folder. These
# daily downloads will then be used to come up with the logic to determine
# which dogs are "new" as well as how to increment the "days on petfinder" count
dev_daily_download <- function(...) {

  dpet <- get_p_find(location = "washington, dc", count = 1000, ...)

  # stragely the API will return a 200 response code sometimes, even when
  # there was an error. the API returns the response always as XML in these
  # cases
  txt <- httr::content(dpet, "text", encoding = "UTF-8")
  txt <- substr(txt, 1, 500)
  if (httr::http_error(dpet) || er_txt_msg(txt)) {
    send_gmail(body = txt)
    df <- data.frame(time = time_to_fstring(), error = txt)
    write.csv(df, "inst/cron/get-error.csv", row.names = FALSE, append = TRUE)
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

auth_gmail <- function() {
  gmailr::use_secret_file("/run/secrets/gmail")
  gmailr::gmail_auth("compose")
}

send_gmail <- function(body) {
  auth_gmail()
  gmailr::mime(
    From = "pfanalytics787@gmail.com",
    To = "chriscrewbaker@gmail.com"
  ) %>%
    gmailr::text_body(body) %>%
    gmailr::send_message()
}

er_txt_msg <- function(txt) {
  if (grepl("<code>[0-9]{3}</code>", txt, ignore.case = TRUE)) {
    num <- gsub(".*<code>([0-9]{3})</code>.*", "\\1", txt)
    num != "200"
  } else {
    FALSE
  }
}
