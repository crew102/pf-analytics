get_pf_key <- function() {

  env_key <- Sys.getenv("PF_KEY")
  local_file <- "../../services/secrets/PF_KEY"
  dcompose_file <- "/run/secrets/pf-key"

  if (env_key != "") # either in docker container (not compose) or local
    env_key
  else if (file.exists(local_file)) # local
    readLines(file(local_file))
  else if (file.exists(dcompose_file)) # docker compose
    readLines(file(dcompose_file))
  else
    stop("Couldn't find PF API key", call. = FALSE)
}

resp_to_json <- function(response) {
  httr::content(response, "text", encoding = "UTF-8") %>%
    jsonlite::fromJSON()
}

as_vec <- function(x)
  if (is.null(x)) return(NA) else unlist(x, use.names = FALSE)

null_to_na <- function(x) if (is.null(x)) return(NA) else x

add_class <- function(x, class) structure(x, class = c(class(x), class))

maybe_gen_dir <- function(x) if (!dir.exists(x)) dir.create(x)

time_to_fstring <- function() gsub("[^[:digit:]]", "-", Sys.time())

lappy2 <- function(...) sapply(..., USE.NAMES = TRUE, simplify = FALSE)
