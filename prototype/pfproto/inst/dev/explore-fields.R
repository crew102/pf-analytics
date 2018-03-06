library(dplyr)
library(tidyr)
library(devtools)

load_all()

xrep <- p_find(count = 1000)
data <- p_find_to_tibble(xrep)

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
