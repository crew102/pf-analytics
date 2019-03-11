library(dplyr)
library(lubridate)
library(timevis)
library(devtools)

load_all()
files_df <- cache_files()

pet_df <-
  lapply(1:160, function(x) {
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
    filter(start > "2018-04-18") %>%
    mutate(time_on = interval(start, end) / days(1))

content <-
  pet_df %>%
    group_by(pet_id) %>%
    slice(1) %>%
    mutate(breed = sapply(breed, function(x) paste(x, collapse = " | "))) %>%
    mutate(content = paste(name, ":", age, ":", breed)) %>%
    # mutate(content = name) %>%
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

df %>% filter(shelter_id == "DC20", end < "2018-06-01") -> sample_df
sample_df %>% semi_join(x, "pet_id") -> sample_df

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

library(ggplot2)
pet_df %>% group_by(day, shelter_id) %>% count() %>% arrange(day) -> i
  ggplot(i) + geom_line(aes(x = day, y = n, colour = shelter_id))

  df %>% left_join(dbtbls$pet_dof) %>% filter(abs(time_on - dof) > 4) %>% View
