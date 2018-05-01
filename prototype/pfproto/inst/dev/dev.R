library(dplyr)
library(tidyr)
library(devtools)
library(lubridate)
load_all()

file_df <- cache_files()

pool <- create_pool()

gen_db(pool)

if (is_first_day(pool)) {
  write_init_pets(readRDS(file_df$file[1]), pool)
  # update db_update table
} else {
  #  update_db()
}

##### update_db on day 2 (or any other day)

dbtbls <- fetch_all_tables(pool)

existing_pets <- tibble(
  pet_id = c(
    dbtbls$initial_pets$pet_id,
    dbtbls$blacklisted_pets$pet_id,
    dbtbls$pet_tracking$pet_id,
    dbtbls$pet_final_dof$pet_id
  )
)

today_data <- readRDS(file_df$file[2])
today_day <- file_df$date[2]

new_pets <-
  today_data %>%
    anti_join(existing_pets, by = "pet_id") %>%
    mutate(days_since_last_update = interval(last_update, today_day) / days(1)) %>%
    mutate(should_blacklist = abs(days_since_last_update) >= 2)

# update blacklist
new_blacklist <- new_pets %>% filter(should_blacklist)
if (nrow(new_blacklist)) {
  new_tbl_blacklist <- tibble(
    pet_id = c(
      dbtbls$blacklisted_pets$pet_id,
      new_blacklist$pet_id
    )
  )
###  new_tbl_blacklist %>% copy_to2(pool, ., "blacklisted_pets")
}

unnest_one_pftbl <- function(name, df) {
  nd2 <- df[, c("pet_id", name)]
  nd2[!is.na(nd2[, 2]), ] %>% unnest()
}

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
# new_tbl_tracking %>% copy_to2(pool, ., "pet_tracking")

  #### NON-ANALYTICS TABLES UPDATES

if (have_new_tracking) {
  # pet table update
  rbind(dbtbls$pet, new_tracking[, colnames(dbtbls$pet)]) %>% copy_to2(pool, ., "pet")

  # pet long table updates
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


shelter_last_update_today <-
  today_data %>%
    group_by(shelter_id) %>%
    summarise(last_update = max(last_update))

shelter_last_update <-
  rbind(dbtbls$shelter_last_update, shelter_last_update_today) %>%
    group_by(shelter_id) %>%
    summarise(last_update = max(last_update))

# now see if we can update current_dof for pets that have been in tracking tbl
