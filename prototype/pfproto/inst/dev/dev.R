library(dplyr)
library(tidyr)
library(devtools)
library(lubridate)

load_all()
files_df <- cache_files()
pool <- create_pool()

# DAY 1 ---------------------------
# initial_pets

gen_db(pool)

if (is_first_day(pool)) {
  write_init_pets(readRDS(files_df$file[1]), pool)
} else {
  # update db_update table
}

# DAY X first set of "pet tracking" table updates ---------------------------
# blacklisted_pets, pet_tracking
# (db_update, shelter_last_update and pet_dof in second set of updates)

db_update <- function(today_data, today_day, pool) {

  dbtbls <- fetch_all_tables(pool)
  if (nrow(dbtbls$shelter_last_update)) {
    if (!is.POSIXct(dbtbls$shelter_last_update$last_update)) {
      browser()
    }
  }

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
    new_tbl_blacklist <- tibble(
      pet_id = c(
        dbtbls$blacklisted_pets$pet_id,
        new_blacklist$pet_id
      )
    )
    new_tbl_blacklist %>% copy_to2(pool, ., "blacklisted_pets")
  }

  # update pet_tracking table to include the new pets from today
  new_pets_to_track <- new_pets %>% filter(!should_blacklist)
  have_new_tracking <- nrow(new_pets_to_track) != 0
  if (have_new_tracking) {
    new_tbl_tracking <- new_pets_to_track %>%
      mutate(
        first_seen = last_update,
        current_dof = days_since_last_update,
        current_dof_last_update = today_day
      ) %>%
      select(pet_id, first_seen, current_dof, current_dof_last_update) %>%
      rbind(dbtbls$pet_tracking) # add to existing pet_tracking table
  } else {
    new_tbl_tracking <- dbtbls$pet_tracking
  }
  new_tbl_tracking %>% copy_to2(pool, ., "pet_tracking")

  # DAY X info table updates ---------------------------
  # pet, pet_option, pet_breed, pet_photo, shelter
  unnest_one_pftbl <- function(name, df) {
    nd2 <- df[, c("pet_id", name)]
    nd2[!is.na(nd2[, 2]), ] %>% unnest()
  }

  if (have_new_tracking) {
    # pet table update
    rbind(dbtbls$pet, new_pets_to_track[, colnames(dbtbls$pet)]) %>%
      copy_to2(pool, ., "pet")

    # pet_ table updates
    pet_tables <- c("option", "breed", "photo")
    pet_tables_dfs <- lappy2(pet_tables, unnest_one_pftbl, df = new_pets_to_track)

    lappy2(
      pet_tables,
      function(x) rbind(pet_tables_dfs[[x]], dbtbls[[x]]) %>%
        copy_to2(pool, ., paste0("pet_", x))
    )
  }

  today_shelters <-
    today_data %>%
      select(shelter_id, city, state, zip) %>%
      distinct()

  rbind(dbtbls$shelter, today_shelters) %>%
    distinct() %>%
    copy_to2(pool, ., "shelter")

  # DAY X second set of "pet tracking" table updates ---------------------------
  # shelter_last_update
  # let's forget about pet_dof, db_update for now
  shelter_last_update_today <-
    today_data %>%
      group_by(shelter_id) %>%
      summarise(last_update = max(last_update, na.rm = TRUE))
  if (nrow(shelter_last_update_today)) {
    if (!is.POSIXct(shelter_last_update_today$last_update)) {
      browser()
    }
  }

  rbind(dbtbls$shelter_last_update, shelter_last_update_today) %>%
    group_by(shelter_id) %>%
    summarise(last_update = max(last_update, na.rm = TRUE)) %>%
    copy_to2(pool, ., "shelter_last_update")

  # now see if we can update current_dof for pets that have been in pet_tracking:

  # have to use the pet_tracking table that has been updated here b/c on the second
  # day the pet_tracking table that we fetched from db in above code will be
  # empty table...change this to just use existing dbtabls for all days 2+
  dbtbls <- fetch_all_tables(pool)

  pet_tracking <- dbtbls$pet_tracking %>%
    left_join(dbtbls$pet %>% select(pet_id, shelter_id)) %>%
    left_join(dbtbls$shelter_last_update, "shelter_id") %>%
    mutate_at(vars(matches("last_update")), as_datetime) %>%
    mutate(diff_date = interval(current_dof_last_update, last_update) / days(1)) %>%
    mutate(current_dof = ifelse(diff_date > 0, current_dof + diff_date, current_dof)) %>%
    # need to use if_else here so timestamp attribute isn't dropped
    mutate(current_dof_last_update = if_else(diff_date > 0, last_update, current_dof_last_update)) %>%
    select(1:4)

  copy_to2(pool, pet_tracking)
}

db_update(readRDS(files_df$file[2]), files_df$date[2], pool)
db_update(readRDS(files_df$file[3]), files_df$date[3], pool)
db_update(readRDS(files_df$file[4]), files_df$date[4], pool)
db_update(readRDS(files_df$file[5]), files_df$date[5], pool)

db_update(readRDS(files_df$file[6]), files_df$date[6], pool)

db_update(readRDS(files_df$file[7]), files_df$date[7], pool)
