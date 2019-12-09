#' Initializes schema, tables and views
#' @param con PostgreSQL database connection
#' @param schema_name Name of the schema to use
#' @param overwrite If exists, it will delete the existing schema and replace it with the new content
#' @export
bdc_init_db <- function(con, schema_name = "retail", overwrite = FALSE) {
  UseMethod("bdc_init_db")
}

bdc_init_db.PqConnection <- function(con, 
                                     schema_name = "retail", overwrite = FALSE
                                     ) {
  cs <- paste0("SELECT schema_name FROM information_schema.schemata WHERE schema_name = '", schema_name,"';")
  schemas <- dbGetQuery(con, cs)
  if(nrow(schemas) >= 1) {
    if(overwrite) {
      dbExecute(con, paste0("DROP SCHEMA ", schema_name," CASCADE;"))
    } else {
      stop(paste0("The '", schema_name, "'  schema already exists, use overwrite = TRUE to replace its contents"))
    }
  }
  dbExecute(con, paste0("CREATE SCHEMA ", schema_name,";"))
  dbExecute(con, paste0("SET search_path TO ", schema_name,";"))
  con
}

#' Creates an empty SQLite database
#' @param folder Folder location to place the database file
#' @export
bdc_init_sqlite <- function(folder = "database") {
  path <- file.path(folder, "local.sqlite")
  if (file.exists(path)) unlink(path)
  if (!dir.exists(folder)) dir.create(folder)
  dbConnect(RSQLite::SQLite(), path)
}
