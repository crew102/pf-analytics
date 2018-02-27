library(tidyverse)
library(jsonlite)
library(httr)

resp_to_json <- function(response) {
  content(response, "text") %>% 
    fromJSON()
}

p_find <- function(key = Sys.getenv("PFKEY"), 
                   location = "20008", 
                   output = "full", 
                   count = 100, 
                   offset = 1) {
  paste0(
    "http://api.petfinder.com/pet.find?key=", key, 
    "&location=", location,
    "&output=", output,
    "&count=", count,
    "&offset=", offset,
    "&animal=dog",
    "&format=json"
  ) %>% 
    GET() %>%  
    resp_to_json()
}

xrep <- p_find(count = 2)
pet <- xrep$petfinder$pets$pet
