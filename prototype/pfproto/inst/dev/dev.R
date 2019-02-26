library(dplyr)
library(tidyr)
library(devtools)
library(lubridate)

load_all()
files_df <- cache_files()
pool <- create_pool()

gen_db(pool)

db_update <- function(today_data, today_day, pool) {

  dbtbls <- fetch_all_tables(pool)

  # see if any of the pets in the pet_tracking are not in today's data..these
  # are pets that have since been removed since we last updated, so we need to
  # move them over from pet_tracking to pet_dof
  removed_pets <- dbtbls$pet_tracking %>% anti_join(today_data, by = "pet_id")
  dbtbls$pet_dof <- removed_pets %>%
    mutate(dof = interval(first_seen, today_day) / days(1)) %>%
    select(pet_id, dof)
  copy_to2(pool, dbtbls$pet_dof, "pet_dof")

  existing_pets <- tibble(
    pet_id = c(
      dbtbls$initial_pets$pet_id,
      dbtbls$blacklisted_pets$pet_id,
      dbtbls$pet_tracking$pet_id,
      dbtbls$pet_dof$pet_id
    )
  )

  new_pets <-
    today_data %>%
      anti_join(existing_pets, by = "pet_id") %>%
      mutate(days_since_last_update = interval(last_update, today_day) / days(1)) %>%
      # a new pet must not have been seen before and have been recently added to pf (within last 2 days)
      mutate(should_blacklist = abs(days_since_last_update) >= 2)

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

  # update pet_tracking table to include the new pets from today
  new_pets_to_track <- new_pets %>% filter(!should_blacklist)
  have_new_tracking <- nrow(new_pets_to_track) != 0
  if (have_new_tracking) {
    dbtbls$pet_tracking <- new_pets_to_track %>%
      mutate(first_seen = last_update) %>%
      select(pet_id, first_seen) %>%
      rbind(dbtbls$pet_tracking) # add to existing pet_tracking table
    copy_to2(pool, dbtbls$pet_tracking, "pet_tracking")
  }

  # "pet" and "shelter" table update
  if (have_new_tracking) {
    dbtbls$pet <- rbind(dbtbls$pet, new_pets_to_track[, colnames(dbtbls$pet)])
    dbtbls$shelter <-
      today_data %>%
        select(shelter_id, city, state, zip) %>%
        rbind(dbtbls$shelter) %>% # what if shelter changes city/state/zip?
        distinct()
    copy_to2(pool, dbtbls$pet, "pet")
    copy_to2(pool, dbtbls$shelter, "shelter")
  }

  print(today_day)
}

if (is_first_day(pool)) {
  write_init_pets(readRDS(files_df$file[1]), pool)
} else {
  lapply(
    1:35,
    function(x) db_update(readRDS(files_df$file[x]), files_df$date[x], pool)
  )
}
