distinct_pet <- function(citystates) {
  lapply(citystates, p_find_one_city) %>%
    do.call(rbind, .)
}

p_find_one_city <- function(citystate) {
  x <- p_find_one_city_batch(citystate)
  if (nrow(x) == 1000) {
    p_find_one_city_batch(citystate, offset = 1001) %>%
      rbind(x)
  } else {
    x
  }
}

p_find_one_city_batch <- function(citystate, ...) {
  p_find(location = citystate, count = 1000, ...) %>%
    as_pftibble() %>%
    mutate(actual_citystate = as_citystate(city, state)) %>%
    filter(grepl(citystate, actual_citystate, ignore.case = TRUE)) %>%
    select(-actual_citystate)
}
