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
  lapply(cons, function(x) try(DBI::dbDisconnect(x)))
}

fetch_table <- function(pool = create_pool(), table) {
  x <- tbl(pool, table) %>% collect()
  # for some reason datetimes aren't being read in as dates
  if (table == "pet_tracking") {
    x %>% mutate(first_seen = as_datetime(first_seen))
  } else if (table == "shelter_activity") {
    x %>% mutate(activity_date = as_datetime(activity_date))
  } else if (table == "pet_dof") {
    x %>% mutate(first_seen = as_datetime(first_seen), today_day = as_datetime(today_day))
  } else {
    x
  }
}

fetch_all_tables <- function(pool) {
  tables <- db_list_tables(pool)
  lappy2(tables, function(x) fetch_table(pool, x))
}

db_data_type <- function(fields) {
  char_type <- function(x) {
    n <- max(nchar(as.character(x), "bytes"), 0L, na.rm = TRUE)
    if (n <= 65535) {
      paste0("varchar(", n, ")")
    } else {
      "mediumtext"
    }
  }

  data_type <- function(x) {
    switch(
      class(x)[1],
      logical =   "boolean",
      integer =   "integer",
      numeric =   "double",
      factor =    char_type(x),
      character = char_type(x),
      Date =      "date",
      POSIXct =   "datetime",
      stop("Unknown class ", paste(class(x), collapse = "/"), call. = FALSE)
    )
  }
  vapply(fields, data_type, character(1))
}

copy_to2 <- function(conn, df, name, field_types = NULL) {

  db_drop_table(conn, name, force = TRUE)

  if (is.null(field_types))
    field_types <- db_data_type(df)

  db_create_table(conn, name, field_types, temporary = FALSE)

  df <- purrr::modify_if(df, is.logical, as.integer)
  df <- purrr::modify_if(df, is.factor, as.character)
  df <- purrr::modify_if(df, is.character, encodeString, na.encode = FALSE)

  tmp <- tempfile(fileext = ".csv")
  utils::write.table(
    df, tmp, sep = "\t", quote = FALSE, qmethod = "escape",
    na = "\\N", row.names = FALSE, col.names = FALSE
  )
  sql <- paste0(
    "LOAD DATA LOCAL INFILE '", encodeString(tmp), "' INTO TABLE ", name, ";"
  )
  x <- paste0(
    "mysql -uroot -p", get_secret("MYSQL_ROOT_PASSWORD"),
    " -h\"mysql\" -e \"use pf_dev; ", sql, "\""
  )
  system(x)
}
