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

# check if this is the first day, and if it is, write initial pets
maybe_write_init_pets <- function(pftibble, conn) {
  rw1 <- suppressWarnings(tbl(conn, "initial_pets") %>% collect(n = 1))
  if (nrow(rw1) == 0)
    pftibble %>%
      select(pet_id) %>%
      copy_to(pool, ., "initial_pets", temporary = FALSE, overwrite = TRUE)
}

maybe_write_init_pets(readRDS(file_df$file[1]), pool)


