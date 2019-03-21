norm_name <- function(name) {
  gsub("-", " ", name) %>%
    gsub("\\s*\\([^\\)]+\\)", "", .) %>%
    gsub("[[:space:]]{2,}", " ", .) %>%
    stringr::str_trim("both") %>%
    tolower()
}
