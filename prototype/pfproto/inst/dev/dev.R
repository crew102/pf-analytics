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
  # update db_update table
} else {
  #  update_db()
}

# DAY X first set of "pet tracking" table updates ---------------------------
# blacklisted_pets, pet_tracking
# (db_update, shelter_last_update and pet_dof in second set of updates)
dbtbls <- fetch_all_tables(pool)

existing_pets <- tibble(
  pet_id = c(
    dbtbls$initial_pets$pet_id,
    dbtbls$blacklisted_pets$pet_id,
    dbtbls$pet_tracking$pet_id,
    dbtbls$pet_dof$pet_id
  )
)

today_data <- readRDS(files_df$file[2])
today_day <- files_df$date[2]

new_pets <-
  today_data %>%
    anti_join(existing_pets, by = "pet_id") %>%
    mutate(days_since_last_update = interval(last_update, today_day) / days(1)) %>%
    # a new pet must not have been seen before and have been recently added to pf (within last 2 days)
    mutate(should_blacklist = abs(days_since_last_update) >= 2)

# update blacklisted_pets
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

# update pet_tracking table
new_tracking <- new_pets %>% filter(!should_blacklist)
have_new_tracking <- nrow(new_tracking) != 0
if (have_new_tracking) {
  new_tbl_tracking <- new_tracking %>%
    mutate(
      first_seen = last_update,
      current_dof = days_since_last_update,
      current_dof_last_update = today_day
    ) %>%
    select(pet_id, first_seen, current_dof, current_dof_last_update) %>%
    rbind(dbtbls$pet_tracking)
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
  rbind(dbtbls$pet, new_tracking[, colnames(dbtbls$pet)]) %>% copy_to2(pool, ., "pet")

  # pet_ table updates
  pet_tables <- c("option", "breed", "photo")
  pet_tables_dfs <- lappy2(pet_tables, unnest_one_pftbl, df = new_tracking)

  lappy2(
    pet_tables,
    function(x) rbind(pet_tables_dfs[[x]], dbtbls[[x]]) %>% copy_to2(pool, ., x)
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
# db_update, shelter_last_update and pet_dof
shelter_last_update_today <-
  today_data %>%
    group_by(shelter_id) %>%
    summarise(last_update = max(last_update))

shelter_last_update <-
  rbind(dbtbls$shelter_last_update, shelter_last_update_today) %>%
    group_by(shelter_id) %>%
    summarise(last_update = max(last_update))

# now see if we can update current_dof for pets that have been in pet_tracking
