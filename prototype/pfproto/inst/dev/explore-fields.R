library(dplyr)
library(tidyr)
library(devtools)

load_all()

xrep <- p_find(count = 1000)
data <- as_pftibble(xrep)

saveRDS(data, "cache/march-5.rds")

data %>%
  select(id, option) %>%
  unnest(option) %>% View

data %>%
  select(id, shelterId, lastUpdate) %>%
  arrange(shelterId, lastUpdate) %>% View

# date added for pet in question
#
# in future, for each day: check to see if shelter has added, removed, or updated any records
# if no activity, then can't incredment days on petfinder count for that day
# 1. see if petid is still in list. if not, that signals removal
# 2. if petid is still in list, check to see if you can increment the "days on petfinder" count by
# seeing if another pet was updated today and time between now and time of last update for this "other" pet is at least 5 hours

# id, basic, full

nrby_locs_apply(citystate_centers, "citystate") -> test


########### get "good" locations that will be searched for pets...to get a good location, first find nearby cities to given city centers. for each of these nearby cities, search for pets in that city...if there are more than 1000 pets in the city, then search for all

library(dplyr)

init_day <- readRDS("cache/march-5.rds") %>% filter(state == "DC")

day2 <- readRDS("cache/march-9.rds") %>% filter(state == "DC")

day3 <- p_find_one_city("washington, dc")
# saveRDS(day3, "cache/march-20.rds")

## start day = sys.time()

init_time <- Sys.time()

# determine new pets of day for given city
# pull all city pets
# check if pet was in previous day's data...if not,

new_dogs <- function(yesterdays_df, todays_df) {
  todays_df %>%
    anti_join(yesterdays_df, by = "id") %>%
    pull("id")
}

new_dogs(dc_m5, dc_today)


# done on first day
init_yesterday_tbl <- function() {

  # use this in true dev
  # data <- p_find_one_city("washington, dc")

  data <- readRDS("cache/march-5.rds") %>% filter(state == "DC")

  data %>%
    select(id, shelterId) %>%
    saveRDS("cache/db/yesterday.rds")
}

yest <- readRDS("cache/db/yesterday.rds")
today <- readRDS("cache/march-9.rds") %>% filter(state == "DC")


