get_secret <- function(var) {

  env_key <- Sys.getenv(var)
  local_file <- file.path("../../services/secrets", var)
  dcompose_file <- file.path("/run/secrets", gsub("_", "-", tolower(var)))

  if (env_key != "") # local
    env_key
  else if (file.exists(local_file)) # local
    read_lines(file(local_file))
  else if (file.exists(dcompose_file)) # docker compose
    read_lines(file(dcompose_file))
  else
    stop("Couldn't find ", var, call. = FALSE)
}

read_lines <- function(...) suppressWarnings(readLines(...))

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

create_pool <- function(host = "mysql", password = get_secret("MYSQL_ROOT_PASSWORD")) {
  pool::dbPool(
    drv = RMySQL::MySQL(),
    dbname = "pf_dev",
    host = host,
    port = 3306,
    username = "root",
    password = password
  )
}

close_cons <- function() {
  cons <- DBI::dbListConnections(RMySQL::MySQL())
  sapply(cons, function(x) try(DBI::dbDisconnect(x)))
}
