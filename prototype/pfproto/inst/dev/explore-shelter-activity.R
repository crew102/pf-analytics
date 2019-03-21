library(dplyr)
library(lubridate)
library(ggplot2)
library(devtools)

load_all()

pool <- create_pool()
dbtbls <- fetch_all_tables(pool)

dbtbls$pet %>%
  group_by()

pet_dof <- dbtbls$pet %>% filter(!is.na(dof))

top_shelter <- pet_dof %>%
  group_by(shelter_id) %>%
  summarise(n = n()) %>%
  arrange(desc(n)) %>%
  slice(1:5) %>%
  select(shelter_id)

last_days <- pet_dof %>%
  mutate_at(vars(matches("seen")), as_date) %>%
  inner_join(top_shelter) %>%
  group_by(shelter_id, first_day_not_seen) %>%
  count()

ggplot(last_days, aes(x = first_day_not_seen, y = n)) +
  geom_bar(stat = "identity") +
  facet_wrap(~shelter_id, ncol = 1, scales = "free") +
  scale_x_date()
