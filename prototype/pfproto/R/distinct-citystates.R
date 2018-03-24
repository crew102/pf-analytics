# Function to find all distinct citystates that are close to a given citystate
# center
distinct_citystates <- function(citystate_centers) {
  lapply(citystate_centers, nrby_citystates) %>%
    do.call(c, .) %>%
    unique()
}

citystate_centers <- c(
  "washington, dc",
  "new york, ny"
)

nrby_citystates <- function(citystate) {
  p_find(location = citystate, count = 1000) %>%
    as_pftibble() %>%
    select(city, state, zip) %>%
    mutate(citystate = as_citystate(city, state)) %>%
    pull("citystate") %>%
    unique()
}

as_citystate <- function(city, state) sprintf("%s, %s", city, state)
