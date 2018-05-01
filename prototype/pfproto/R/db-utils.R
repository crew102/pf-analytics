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

copy_to2 <- function(...) copy_to(..., temporary = FALSE, overwrite = TRUE)

fetch_table <- function(pool, table) tbl(pool, table) %>% collect()

fetch_all_tables <- function(pool) {
  tables <- db_list_tables(pool)
  lappy2(tables, function(x) fetch_table(pool, x))
}
