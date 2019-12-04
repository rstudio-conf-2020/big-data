setup_sqlite <- function(avg_daily_orders = 1000, no_products = 30, avg_no_items = 3,
                         days_in_segment = 10, no_of_segments = 100, start_date = "2016-01-01", 
                         seed_number = 7878, transactions_days = 30, no_customers = 90, 
                         no_transactions = 100000, batch_size = 10000, no_files = 5,
                         transactions_path = "data/",
                         db_path = "assets/setup/database/local.sqlite",
                         customer_path = "assets/setup/database/customers.csv"
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
}

init_process <- function(seed_number = 7878) {
  packages <- c("dplyr", "tibble", "purrr", "lubridate", "DBI", "glue", "dbplyr")
  lapply(packages, library, character.only = TRUE)
  set.seed(seed_number)
}

db_init_sqlite <- function(path) {
  if(file.exists(path)) unlink(path)
  dbConnect(RSQLite::SQLite(), path)
}

db_write_customers <- function(con, path = "setup/database/customers.csv") {
  dbWriteTable(
    con, 
    "customers", 
    readr::read_csv(path), 
    overwrite = TRUE
  )
}

db_write_products <- function(con, no_products) {
  tibble(
    price = round(runif(no_products, 4, 10), 2)
  ) %>%
    rowid_to_column("product_id") %>%
    dbWriteTable(con, "products", .)
}

db_write_date <- function(con, start_date, days_in_segment, no_of_segments) {
  step_id <- seq_len(days_in_segment * no_of_segments)
  step_date <-  start_date + (step_id - 1)
  tibble(
    step_id,
    order_date = as.character(step_date),
    order_date_year = year(step_date),
    order_date_month = month(step_date),
    order_date_month_name = month(step_date, label = TRUE),
    order_date_quarter = quarter(step_date), 
    order_date_day = format(step_date, "%A")
  ) %>%
    dbWriteTable(con, "dates", .)
}

db_write_transactions <- function(con, days_in_segment, no_of_segments, avg_daily_orders, 
                                  avg_no_items, no_customers, no_products) {
  print("Database ---")
  to <- 0
  for(i in 1:no_of_segments) {
    day_rpois <- rpois(1000, lambda = avg_daily_orders) 
    day_probs <- table(day_rpois) / sum(day_rpois)
    day_count <- sample(
      as.integer(names(table(day_rpois))), 
      size = days_in_segment, replace = TRUE, prob = day_probs
      )
    day_size <- sum(day_count)
    day_id <- seq_along(day_count) %>%
      map(~rep(.x, times = day_count[.x])) %>%
      reduce(c)
    days <- tibble(day_id) %>%
      rowid_to_column("order_id")
    order_rpois <- rpois(1000, lambda = avg_no_items - 1) + 1
    order_probs <- table(order_rpois) / sum(order_rpois)
    order_count <- sample(length(order_probs), size = day_size, 
                          replace = TRUE, prob = order_probs)
    order_size <- sum(order_count)
    order_id <- seq_along(order_count) %>%
      map(~rep(.x, times = order_count[.x])) %>%
      reduce(c)
    
    customer_probs <- sample(100, size = no_customers) / 100
    customer_count <- sample(no_customers, size = day_size, 
                             replace = TRUE, prob = customer_probs )
    customer_id <- seq_along(customer_count) %>%
      map(~rep(customer_count[.x], times = order_count[.x])) %>%
      reduce(c)
    
    product_probs <- sample(100, size = no_products) / 100
    product_id <- sample(no_products, size = order_size, 
                         replace = TRUE, prob = product_probs )
    
    transactions <- tibble(
      order_id,
      customer_id,
      product_id
    ) %>%
      inner_join(days, by = "order_id") %>%
      mutate(
        step_id = day_id + (days_in_segment * (i - 1)),
        transaction_id = row_number() + to
        ) %>%
      mutate(
        order_id = as.integer((step_id * 1000) + order_id)
        ) %>%
      select(-day_id) %>%
      select(transaction_id, step_id, everything())
    
    from <- min(transactions$transaction_id)
    to <- max(transactions$transaction_id)
    
    dbWriteTable(con, "transactions", transactions, append = TRUE)
    print(paste0(i, " of ", no_of_segments, " complete- From: ", from, " - to: ", to))
  }
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

transaction_to_file <- function(filename = NULL, delimeter = NULL, ...) {
  cat(
    paste0(paste(..., sep = delimeter), "\n"),
    file = filename,
    append = TRUE
  )
}

random_range <- function(from, to, size) {
  fctr <- 1000000
  from <- from * fctr
  to <- to * fctr
  sample(from:to, size)  / fctr
}

save_customers <- function(no_customers = 90, 
                           path = "assets/setup/database/customers.csv") {
  init_process()
  lat <- c(37.788432, 37.727631)
  long <- c(-122.485262, -122.398601)
  tibble(
    customer_name = charlatan::ch_name(no_customers),
    customer_phone = charlatan::ch_phone_number(no_customers),
    customer_cc = charlatan::ch_credit_card_number(no_customers),
    customer_lon = random_range(long[1], long[2], no_customers),
    customer_lat = random_range(lat[1], lat[2], no_customers)
  ) %>%
    rowid_to_column("customer_id") %>%
    readr::write_csv(path)
}

create_text_files <- function() {
  library(gutenbergr)
  library(dplyr)
  
  gutenberg_works()  %>%
    filter(author == "Doyle, Arthur Conan") %>%
    pull(gutenberg_id) %>%
    gutenberg_download() %>%
    pull(text) %>%
    writeLines("books/arthur_doyle.txt")
  
  gutenberg_works()  %>%
    filter(author == "Twain, Mark") %>%
    pull(gutenberg_id) %>%
    gutenberg_download() %>%
    pull(text) %>%
    writeLines("books/mark_twain.txt")
}


