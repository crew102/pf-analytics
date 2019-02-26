library(dplyr)
library(lubridate)
library(timevis)
library(devtools)

load_all()
files_df <- cache_files()

pet_df <-
  lapply(1:35, function(x) {
    readRDS(files_df$file[x]) %>%
      mutate(day = files_df$date[x])
  }) %>%
    do.call(rbind, .) %>%
    arrange(shelter_id, pet_id, day)

start_end <-
  pet_df %>%
    group_by(pet_id, shelter_id) %>%
    summarise(start = min(last_update), end = max(day)) %>%
    mutate_at(vars(start, end), funs(round_date(., "day"))) %>%
    filter(start > "2018-03-28") %>%
    filter(start > "2018-04-18")

content <-
  pet_df %>%
    group_by(pet_id) %>%
    slice(1) %>%
    mutate(breed = sapply(breed, function(x) paste(x, collapse = " | "))) %>%
    mutate(content = paste(age, ":", breed)) %>%
    select(pet_id, content)

df <- start_end %>% inner_join(content)

## now explore the timelines for some of the dogs in a given shelter

df %>% group_by(shelter_id) %>% count() %>% arrange(desc(n))

sample_df <-
  df %>%
    group_by(shelter_id) %>%
    sample_n(50, replace = T) %>%
    distinct() %>%
    filter(shelter_id == "DC19")

timevis(sample_df)

# explore relationships between vars and days on petfinder

to_join <- pet_df %>% group_by(pet_id) %>% slice(1)

vars <-
  df %>%
    filter(end < "2018-05-20") %>%
    mutate(days_on = interval(start, end) / days(1)) %>%
    select(pet_id, days_on) %>%
    inner_join(to_join)

vars %>%
  tidyr::unnest(breed) %>%
  group_by(breed) %>%
  summarise(med = mean(days_on), num = n()) %>%
  filter(num > 20) %>%
  arrange(desc(med))
