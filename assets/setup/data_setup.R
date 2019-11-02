setup_sqlite <- function(avg_daily_orders = 2000, no_products = 30, avg_no_items = 3,
                         days_in_segment = 10,no_of_segments = 100, start_date = "2016-01-01", 
                         seed_number = 7878, transactions_days = 30, no_customers = 90, 
                         transactions_path = "data/transactions.csv",
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
                        avg_daily_orders, avg_no_items, no_customers, 
                        no_products)
  db_create_file(con, transactions_path, transactions_days, start_date)
  dbDisconnect(con)
}

init_process <- function(seed_number = 7878) {
  packages <- c("dplyr", "tibble", "purrr", "lubridate", "DBI")
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
    order_date_quarter = quarter(step_date), 
    order_date_day = format(step_date, "%A")
  ) %>%
    dbWriteTable(con, "dates", .)
}

db_write_transactions <- function(con, days_in_segment, no_of_segments, avg_daily_orders, 
                                  avg_no_items, no_customers, no_products) {
  print("Database ---")
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
      mutate(step_id = day_id + (days_in_segment * (i - 1))) %>%
      select(-day_id) %>%
      select(step_id, everything())
    
    dbWriteTable(con, "transactions", transactions, append = TRUE)
    print(paste0(i, " of ", no_of_segments, " complete"))
  }
}

db_create_file <- function(con, transactions_path, transactions_days, start_date) {
  transactions <- tbl(con, "transactions") %>%
    inner_join(tbl(con, "dates"), by = "step_id") %>%
    inner_join(tbl(con, "customers"), by = "customer_id") %>%
    inner_join(tbl(con, "products"), by = "product_id") %>%
    select(order_id, contains("order_date"), contains("customer_"), everything()) %>%
    select(-step_id)
  if(file.exists(transactions_path)) unlink(transactions_path)
  print("Transaction file ---")
  for(i in seq_len(transactions_days)) {
    day_trans <- transactions %>%
      filter(order_date == !! as.character(start_date + (i - 1))) %>%
      collect()
    if(i == 1) {
      readr::write_csv(day_trans, transactions_path)  
    } 
    else {
      readr::write_csv(day_trans, transactions_path, append = TRUE)  
    }
    print(paste0(i, " of ", transactions_days, " complete"))
  }
}

save_customers <- function(no_customers, path = "setup/database/customers.csv") {
  tibble(
    customer_name = charlatan::ch_name(no_customers),
    customer_phone = charlatan::ch_phone_number(no_customers),
    customer_cc = charlatan::ch_credit_card_number(no_customers),
    customer_lon = charlatan::ch_lon(no_customers),
    customer_lat = charlatan::ch_lat(no_customers)
  ) %>%
    rowid_to_column("customer_id") %>%
    readr::write_csv(path)
}