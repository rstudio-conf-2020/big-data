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

db_create_view_sqlite <- function(con) {
  transactions <- tbl(con, "transactions") %>%
    inner_join(tbl(con, "dates"), by = "step_id") %>%
    inner_join(tbl(con, "customers"), by = "customer_id") %>%
    inner_join(tbl(con, "products"), by = "product_id") %>%
    select(transaction_id, order_id, contains("order_date"), contains("customer_"), everything()) %>%
    select(-step_id)
  transactions_sql <- remote_query(transactions)
  full_sql <- glue_sql("CREATE VIEW v_transactions AS ", transactions_sql)
  dbSendQuery(con, full_sql)
}

db_create_orders_sqlite <- function(con) {
  orders <- tbl(con, "transactions") %>%
    inner_join(tbl(con, "dates"), by = "step_id") %>%
    inner_join(tbl(con, "customers"), by = "customer_id") %>%
    inner_join(tbl(con, "products"), by = "product_id") %>%
    group_by(order_id, order_date, order_date_year, 
             order_date_month, customer_id, customer_name,
             customer_lon, customer_lat) %>%
    summarise(order_total = sum(price), order_qty = n())
  orders_sql <- remote_query(orders)
  full_sql <- glue_sql("CREATE VIEW v_orders AS ", orders_sql)
  dbSendQuery(con, full_sql)
}

db_create_file <- function(con, transactions_path, no_transactions, batch_size, no_files) {
  transactions <- tbl(con, "v_transactions") 
  csv_files <- list.files(transactions_path, "*.csv")
  unlink(file.path(transactions_path, csv_files))
  for(j in seq_len(no_files)) {
    print(paste0("Transaction file ", j, " of ", no_files," ---"))
    file_batch <- (j - 1) * no_transactions
    total_segments <- no_transactions/batch_size
    for(i in seq_len(total_segments)) {
      from <- 1 + (batch_size * (i - 1)) + file_batch
      to <- batch_size * (i) + file_batch
      file_path <- paste0(transactions_path, "transactions_", j, ".csv")
      day_trans <- transactions %>%
        filter(
          transaction_id >= from, 
          transaction_id <= to
        ) %>%
        collect()
      if(i == 1) {
        vroom::vroom_write(day_trans, file_path, ",")
      } 
      else {
        vroom::vroom_write(day_trans, file_path, ",", append = TRUE)
      }
      print(paste0(i, " of ", total_segments, " complete - From: ", from, " - to: ", to))
    }
  }
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
