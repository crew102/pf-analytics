# this will create the schema, but we'll just be writing over the table defs
# anyways in the dev code.
gen_db <- function(pool) {
  run_q(file("inst/sql/create-db.sql"), pool)
}

is_first_day <- function(pool) {
  suppressWarnings(tbl(pool, "initial_pets") %>% collect(n = 1)) %>% nrow() == 0
}

write_init_pets <- function(pftibble, pool) {
  pftibble %>%
    select(pet_id) %>%
    copy_to2(pool, ., "initial_pets")
}
