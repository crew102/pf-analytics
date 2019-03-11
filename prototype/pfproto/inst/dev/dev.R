library(dplyr)
library(tidyr)
library(devtools)
library(lubridate)
library(stringr)

load_all()
files_df <- cache_files()
pool <- create_pool()

gen_db(pool)

db_update <- function(today_data, today_day, pool) {

  # if (today_day > "2018-05-15" && today_day < "2018-05-28") {
  #   browser()
  # }

  dbtbls <- fetch_all_tables(pool)

  tracking_pet <- dbtbls$pet %>% filter(is.na(dof))

  # we look for changed ids amongst pets we're tracking at have supposedly been
  # removed from petfinder based on their ids. an id is considered changed if
  # we're tracking it, its id can be found in today's data, but its shelter_id,
  # name (cleaned), age, size are all found in today's data
  today_data <- today_data %>%
    mutate(name = gsub("\\s*\\([^\\)]+\\)", "", name)) %>%
    mutate(name = str_trim(name, "both"))

  changed_ids <- tracking_pet %>%
    anti_join(today_data, by = "pet_id") %>%
    inner_join(today_data, by = c("shelter_id", "name", "age", "size")) %>%
    select(pet_id.x, pet_id.y) %>%
    rename(original_pet_id = pet_id.x, new_pet_id = pet_id.y)

  # update today data by subing in old ids for those pets that have a changed
  # id
  today_data <- today_data %>%
    left_join(changed_ids, by = c("pet_id" = "new_pet_id")) %>%
    mutate(pet_id = ifelse(is.na(original_pet_id), pet_id, original_pet_id)) %>%
    select(-original_pet_id)

  # a pet may have been removed on a previous day (<= 5 days in the past) and
  # has been added back today. we need to set make his/her first_day_not_seen
  # value back to NA
  pet0 <-
    dbtbls$pet %>%
      mutate(
        first_day_not_seen = if_else(
          !is.na(first_day_not_seen) & pet_id %in% today_data$pet_id & is.na(dof),
          as.POSIXct(NA),
          first_day_not_seen
        )
      )

  # set first_day_not_seen for those pets that have been removed
  removed_pets <- tracking_pet %>% anti_join(today_data, by = "pet_id")

  pet1 <- pet0 %>%
    mutate(
      first_day_not_seen = if_else(
        pet_id %in% removed_pets$pet_id & is.na(first_day_not_seen),
        today_day, # add first_day_not_seen if it's the first time
        first_day_not_seen
      )
    )

  # see if we can set dof for those pets that have been removed on a previous
  # day. we'll only set a final value for dof when it's been 5 or more days
  # since the pet was first removed. in other words, we'll wait 5 days to see
  # if the pet comes back online before we consider it "off petfinder"
  pet2 <- pet1 %>%
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
        interval(first_seen, first_day_not_seen) / days(1),
        as.double(dof)
      )
    ) %>%
    select(-days_since)


  # now work on new pets (added today)
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
      # a new pet must not have been seen before and have been recently added to pf (within last 5 days)
      mutate(should_blacklist = abs(days_since_last_update) >= 5)

  new_blacklist <- new_pets %>% filter(should_blacklist)
  if (nrow(new_blacklist)) {
    dbtbls$blacklisted_pets <- tibble(
      pet_id = c(
        dbtbls$blacklisted_pets$pet_id,
        new_blacklist$pet_id
      )
    )
    copy_to2(pool, dbtbls$blacklisted_pets, "blacklisted_pets")
  }

  pet3 <- new_pets %>%
    filter(!should_blacklist) %>%
    rename(first_seen = last_update) %>%
    select(pet_id, shelter_id, name, age, size, sex, first_seen) %>%
    mutate(first_day_not_seen = as.POSIXct(NA), dof = NA) %>%
    rbind(pet2)

  copy_to2(pool, pet3, "pet")

  print(today_day)
}

if (is_first_day(pool)) {
  write_init_pets(readRDS(files_df$file[1]), pool)
}
lapply(
    2:100,
    function(x) db_update(readRDS(files_df$file[x]), files_df$date[x], pool)
)

