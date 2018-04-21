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

read_lines <- function(conn, ...) {
  on.exit(close(conn))
  suppressWarnings(readLines(conn, ...))
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

## db utils

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

run_q <- function(query, conn) UseMethod("run_q")

run_q.character <- function(query, conn)
  suppressWarnings(pool::dbGetQuery(conn = conn, statement = query))

run_q.file <- function(query, conn) {
  fi <- read_lines(query)
  nocomments <- gsub("#.*", "", fi)
  j <- paste0(nocomments, collapse = " ")
  queries <- unlist(strsplit(j, ";"))
  queries <- queries[nchar(queries) >= 3]
  lapply(queries, run_q, conn = conn)
}

close_cons <- function() {
  cons <- DBI::dbListConnections(RMySQL::MySQL())
  sapply(cons, function(x) try(DBI::dbDisconnect(x)))
}
