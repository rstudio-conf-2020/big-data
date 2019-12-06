setup_sqlite <- function(avg_daily_orders = 1000, no_products = 30, avg_no_items = 3,
                         days_in_segment = 10, no_of_segments = 100, start_date = "2016-01-01", 
                         seed_number = 7878, transactions_days = 30, no_customers = 90, 
                         no_transactions = 100000, batch_size = 10000, no_files = 5,
                         transactions_path = "data/",
                         db_path = "database/local.sqlite",
                         customer_path = "database/customers.csv"
) {
  init_process(seed_number)
  start_date <- date(start_date)
  con <- db_init_sqlite(db_path)
  db_write_customers(con, customer_path)
  db_write_products(con, no_products)
  db_write_date(con, start_date, days_in_segment, no_of_segments)
  db_write_transactions(con, days_in_segment, no_of_segments, 
                        avg_daily_orders, avg_no_items, 
                        no_customers, no_products)
  db_create_view_sqlite(con)
  db_create_orders_sqlite(con)
  db_create_file(con, transactions_path, no_transactions, batch_size, no_files)
  dbDisconnect(con)
  copy_to_workbook()
}

#' @param path Folder and file name location to place the database file
#' @export
bdc_init_sqlite <- function(path = "database/local.sqlite") {
  if(file.exists(path)) unlink(path)
  dbConnect(RSQLite::SQLite(), path)
}




random_range <- function(from, to, size) {
  fctr <- 1000000
  from <- from * fctr
  to <- to * fctr
  sample(from:to, size)  / fctr
}




create_doyle_twain <- function(path = "books") {
  if(!dir.exists(path)) dir.create(path)
  gutenberg_works()  %>%
    filter(author == "Doyle, Arthur Conan") %>%
    pull(gutenberg_id) %>%
    gutenberg_download() %>%
    pull(text) %>%
    writeLines(file.path(path, "arthur_doyle.txt"))
  
  gutenberg_works()  %>%
    filter(author == "Twain, Mark") %>%
    pull(gutenberg_id) %>%
    gutenberg_download() %>%
    pull(text) %>%
    writeLines(file.path(path, "mark_twain.txt"))
}

copy_to_workbook <- function() {
  unlink("assets/workbook/data", recursive = TRUE, force = TRUE)
  dir.create("assets/workbook/data")
  file.copy("data", "assets/workbook/", recursive = TRUE)
  # Books for the text mining unit
  unlink("assets/workbook/books", recursive = TRUE, force = TRUE)
  dir.create("assets/workbook/books")
  file.copy("books", "assets/workbook/", recursive = TRUE)
  # Database
  unlink("assets/workbook/database", recursive = TRUE, force = TRUE)
  dir.create("assets/workbook/database")
  file.copy("database", "assets/workbook/", recursive = TRUE)
}
