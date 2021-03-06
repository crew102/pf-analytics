# get petfinder data for a given location
get_p_find <- function(pf_key = get_secret("PF_KEY"),
                       location = "20008",
                       output = "full",
                       count = 100,
                       offset = 1) {
  paste0(
    "http://api.petfinder.com/pet.find?key=", pf_key,
    "&location=", utils::URLencode(location),
    "&output=", output,
    "&count=", count,
    "&offset=", offset,
    "&animal=dog",
    "&format=json"
  ) %>%
    httr::GET()
}

parse_p_find <- function(resp) {

  json <- resp_to_json(resp)
  pet <- json$petfinder$pets$pet

  tibble(
    # fields in "pet" table
    pet_id = as.numeric(pet$id$`$t`),
    shelter_id = pet$shelterId$`$t`,
    name = pet$name$`$t`,
    status = pet$status$`$t`,
    age = pet$age$`$t`,
    size = pet$size$`$t`,
    sex = pet$sex$`$t`,
    mix = pet$mix$`$t`,
    description = pet$description$`$t`,

    # fields that create pet_(option|breed|photo) tables
    option = lapply(pet$options$option, as_vec),
    breed = lapply(pet$breeds$breed, as_vec),
    photo = lapply(pet$media$photos$photo, null_to_na),

    last_update = lubridate::as_datetime(pet$lastUpdate$`$t`),

    # shelter fields
    city = pet$contact$city$`$t`,
    state = pet$contact$state$`$t`,
    zip = pet$contact$zip$`$t`,
    email = pet$contact$email$`$t`
  )
}
