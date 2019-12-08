#' Creates an empty SQLite database
#' @param folder Folder location to place the database file
#' @export
bdc_init_sqlite <- function(folder = "database") {
  path <- file.path(folder, "local.sqlite")
  if (file.exists(path)) unlink(path)
  if (!dir.exists(folder)) dir.create(folder)
  dbConnect(RSQLite::SQLite(), path)
}

#' Initializes schema, tables and views
#' @param con PostgreSQL database connection
#' @export
bdc_init_db <- function(con) {
  UseMethod("bdc_init_db")
}

bdc_init_db.PqConnection <- function(con) {
  cs <- "SELECT schema_name FROM information_schema.schemata WHERE schema_name = 'datawarehouse';"
  schemas <- dbGetQuery(con, cs)
  if(nrow(schemas) >= 1) {
    dbExecute(con,"DROP SCHEMA datawarehouse CASCADE;")  
  }
  dbExecute(con,"CREATE SCHEMA datawarehouse;")
  dbExecute(con,"SET search_path TO datawarehouse;")
  con
}
