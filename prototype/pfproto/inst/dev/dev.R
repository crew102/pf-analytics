library(dplyr)
library(tidyr)
library(devtools)
library(lubridate)

load_all()
files_df <- cache_files()
pool <- create_pool()

gen_db(pool)

db_update <- function(today_data, today_day, pool) {

  browser()
  dbtbls <- fetch_all_tables(pool)

  tracking_pet <- dbtbls$pet %>% filter(is.na(dof))

  # we look for changed ids amongst pets we're tracking at have supposedly been
  # removed from petfinder based on their ids. an id is considered changed if
  # we're tracking it, its id can be found in today's data, but its shelter_id,
  # name, age, size are all found in today's data
  changed_ids <- tracking_pet %>%
    anti_join(today_data, by = "pet_id") %>%
    inner_join(today_data, by = c("shelter_id", "name", "age", "size")) %>%
    select(pet_id.x, pet_id.y) %>%
    rename(original_pet_id = pet_id.x, new_pet_id = pet_id.y)

  if (nrow(changed_ids)) {
    browser()
  }

  # update today data by subing in old ids for those pets that have a changed
  # id
  today_data <- today_data %>%
    left_join(changed_ids, by = c("pet_id" = "new_pet_id")) %>%
    mutate(pet_id = ifelse(is.na(original_pet_id), pet_id, original_pet_id)) %>%
    select(-original_pet_id)

  # ...now we can determine which pets were actually removed
  removed_pets <- tracking_pet %>% anti_join(today_data, by = "pet_id")

  pet1 <- dbtbls$pet %>%
    mutate(
      first_day_not_seen = if_else(
        pet_id %in% removed_pets$pet_id & is.na(first_day_not_seen),
        today_day, # add first_day_not_seen if it's the first time
        first_day_not_seen
      )
    ) %>%
    mutate(
      days_since = if_else(
        pet_id %in% removed_pets$pet_id & !is.na(first_day_not_seen),
        interval(first_day_not_seen, today_day) / days(1),
        0
      )
    ) %>%
    mutate(
      dof = if_else(
        days_since >= 5,
        interval(first_seen, today_day) / days(1),
        as.double(dof)
      )
    ) %>%
    select(-days_since)


  # figue out what the new pets are and add them to pet1
  existing_pets <- tibble(
    pet_id = c(
      dbtbls$initial_pets$pet_id,
      dbtbls$blacklisted_pets$pet_id,
      pet1$pet_id
    )
  )

  new_pets <-
    today_data %>%
      anti_join(existing_pets, by = "pet_id") %>%
      mutate(days_since_last_update = interval(last_update, today_day) / days(1)) %>%
      # a new pet must not have been seen before and have been recently added to pf (within last 2 days)
      mutate(should_blacklist = abs(days_since_last_update) >= 5)

  # update blacklisted_pets
  # blackedlisted pets are those new pets (pet_ids we haven't seen before) that
  # have a last_update date that puts their last_update 2 or more days ago.
  new_blacklist <- new_pets %>% filter(should_blacklist)
  if (nrow(new_blacklist)) {
    dbtbls$blacklisted_pets <- tibble(
      pet_id = c(
        dbtbls$blacklisted_pets$pet_id,
        new_blacklist$pet_id
      )
    )
  }
  copy_to2(pool, dbtbls$blacklisted_pets, "blacklisted_pets")

  # update pet to include the new pets from today
  pet2 <- new_pets %>%
    filter(!should_blacklist) %>%
    rename(first_seen = last_update) %>%
    select(pet_id, shelter_id, name, age, size, sex, first_seen) %>%
    mutate(first_day_not_seen = as.POSIXct(NA), dof = NA) %>%
    rbind(pet1)

  copy_to2(pool, pet2, "pet")

  print(today_day)
}

if (is_first_day(pool)) {
  write_init_pets(readRDS(files_df$file[1]), pool)
}
lapply(
    2:100,
    function(x) db_update(readRDS(files_df$file[x]), files_df$date[x], pool)
)

