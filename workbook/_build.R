## Install development version of bigdataclass
library(devtools)
install_github("edgararuiz/bigdataclass", ref = "3f323")

## Load libraries
library(bigdataclass)
library(DBI)

## Open database connection
con <- dbConnect(RPostgres::Postgres(),
                 host = "localhost",
                 user = "rstudio_admin",
                 port = 5432,
                 password = "admin_user_be_careful",
                 dbname = "postgres",
                 bigint = "integer")
folder <- "/usr/share/class"
if(!dir.exists(folder)) stop("Folder ", folder, " not found. Please create it and re-run")

## Creates the "retail" schema inside the database connection
con <- bdc_db_init(con, overwrite = TRUE)

## Creates the tables and views inside the schema
bdc_db_tables(con = con, avg_daily_orders = 1000)

## Builds the files and saves them to the path in "folder" 
files_folder <- file.path(folder, "files")
if(!dir.exists(files_folder)) dir.create(files_folder)
bdc_data_files(con = con, folder = files_folder)

## Downloads the books from the Gutenbergh API and saves them to the "folder"
books_folder <- file.path(folder, "books")
if(!dir.exists(books_folder)) dir.create(books_folder)
bdc_data_books(file.path(folder, "books"))
