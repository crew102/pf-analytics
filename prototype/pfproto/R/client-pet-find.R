# get petfinder data for a given location
p_find <- function(pf_key = get_secret("PF_KEY"),
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
    httr::GET() %>%
    resp_to_json()
}

# get petfinder data for a given pet (used for investigating API's data model)
p_find_id <- function(pf_key = get_secret("PF_KEY"), pet_id) {
  paste0(
    "http://api.petfinder.com/pet.get?key=", pf_key,
    "&id=", pet_id,
    "&format=json"
  ) %>%
    httr::GET() %>%
    httr::content("text", encoding = "UTF-8")
}

as_pftibble <- function(p_find_out) {

  pet <- p_find_out$petfinder$pets$pet

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
    zip = pet$contact$zip$`$t`
  )
}
