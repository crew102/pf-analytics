library(dplyr)
library(tidyr)
library(devtools)

file <- list.files("cache", full.names = TRUE)
file_df <- tibble(
  file = file,
  date = lubridate::parse_date_time(gsub("[^[:digit:]-]", "", file), "ymdHMS")
) %>%
  arrange(date)

pool <- create_pool()

# this will create the schema, but we'll just be writing over the table defs anyways in the dev code.
run_q(file("inst/sql/create-db.sql"), pool)

# check if this is the first day
is_first_day <- function(conn) {
  rw1 <- suppressWarnings(tbl(conn, "db_update") %>% collect(n = 1))
  nrow(rw1) == 0
}

write_init_pets <- function(pftibble, conn) {
  pftibble %>%
    select(pet_id) %>%
    copy_to(conn, ., "initial_pets", temporary = FALSE, overwrite = TRUE)
}

fday <- is_first_day(pool)

if (fday) {
  write_init_pets(readRDS(file_df$file[1]), pool)
} else {
#  update_db()
}

file_df$file[2]
