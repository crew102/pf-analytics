p_find <- function(pf_key = get_pf_key(),
                   location = "20008",
                   output = "full",
                   count = 100,
                   offset = 1) {
  location <- ifelse(
    is.character(location), utils::URLencode(location), location
  )
  paste0(
    "http://api.petfinder.com/pet.find?key=", pf_key,
    "&location=", location,
    "&output=", output,
    "&count=", count,
    "&offset=", offset,
    "&animal=dog",
    "&format=json"
  ) %>%
    httr::GET() %>%
    resp_to_json()
}

as_pftibble <- function(p_find_out) {

  pet <- p_find_out$petfinder$pets$pet

  tibble(
    id = pet$id$`$t`,
    shelter_pet_id = pet$shelterPetId$`$t`,
    name = pet$name$`$t`,
    shelter_id = pet$shelterId$`$t`,
    last_update = lubridate::as_datetime(pet$lastUpdate$`$t`),
    option = lapply(pet$options$option, as_vec),
    status = pet$status$`$t`,
    city = pet$contact$city$`$t`,
    state = pet$contact$state$`$t`,
    zip = as.numeric(pet$contact$zip$`$t`),
    age = pet$age$`$t`,
    size = pet$size$`$t`,
    breed = lapply(pet$breeds$breed, as_vec),
    sex = pet$sex$`$t`,
    mix = pet$mix$`$t`,
    description = pet$description$`$t`,
    photo = lapply(pet$media$photos$photo, null_to_na)
  ) %>%
    add_class("pftibble")
}
