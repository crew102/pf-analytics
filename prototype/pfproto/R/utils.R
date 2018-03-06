get_pf_key <- function() {
  env_key <- Sys.getenv("PF_KEY")
  if (env_key == "")
    readLines(file("../../services/secrets/PF_KEY"))
  else
    env_key
}

resp_to_json <- function(response) {
  httr::content(response, "text") %>%
    jsonlite::fromJSON()
}

as_vec <- function(x)
  if (is.null(x)) return(NA) else unlist(x, use.names = FALSE)

null_to_na <- function(x) if (is.null(x)) return(NA) else x
