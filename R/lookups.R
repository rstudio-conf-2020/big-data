#' @param con Database connection
#' @param product_data Data for the products table
#' @param customer_data Data for the customer table
#' @export
bdc_db_lookups <- function(con,
                           product_data = bdc_create_products(),
                           customer_data = bigdataclass::customers
                           ) {
  UseMethod("bdc_db_lookups")
}

#' @export
bdc_db_lookups.connConnection <- function(con,
                                            product_data = bdc_create_products(),
                                            customer_data = bigdataclass::customers
) { 
  bdc_db_lookups(
    con@con,
    product_data = bdc_create_products(),
    customer_data = bigdataclass::customers    
  )
}

#' @export
bdc_db_lookups.SQLiteConnection <- function(con,
                                            product_data = bdc_create_products(),
                                            customer_data = bigdataclass::customers
                                            ) {
  dbWriteTable(con, "product",  product_data, overwrite = TRUE)
  dbWriteTable(con, "customer", customer_data, overwrite = TRUE)
}

#' Returns a tibble with a product ID and a randomly assigned price
#' @param no_products Number of products to produce
#' @param seed Seed number to use for random data
#' @param price_low Lowest price to assign
#' @param price_high Highest price to assign
#' @export
bdc_create_products <- function(no_products = 30, seed = 7878,
                                price_low = 4, price_high = 10
) {
  set.seed(seed)
  ts <- tibble(
    price = round(runif(no_products, price_low, price_high), 2)
  ) 
  rowid_to_column(ts, "product_id") 
}

#' @param con Database connection
#' @param start_date Start date
#' @export
bdc_db_create_dates <- function(con, start_date = "2016-01-01") {
  step_max <- tbl(con, "order") %>% 
    summarise(max(step_id, na.rm = TRUE)) %>% 
    pull()
  step_id <- seq_len(step_max)
  step_date <- as.Date(start_date) + (step_id - 1)
  tb <- tibble(
    step_id,
    date = as.character(step_date),
    date_year = as.integer(format(step_date, "%Y")),
    date_month = as.integer(format(step_date, "%m")),
    date_month_name = month.abb[as.integer(format(step_date, "%m"))],
    date_day = format(step_date, "%A")
  ) 
  dbWriteTable(con, "date", tb, overwrite = TRUE)
}

create_customers <- function(no_customers = 90, path = "data/customers.rds",
                                 lon_1 = -122.485262, lon_2 = -122.398601,
                                 lat_1 = 37.727631, lat_2 = 37.788432
) {
  tb <- tibble(
    customer_name = ch_name(no_customers),
    customer_phone = ch_phone_number(no_customers),
    customer_cc = ch_credit_card_number(no_customers),
    customer_lon = random_range(lon_1, lon_2, no_customers),
    customer_lat = random_range(lat_1, lat_2, no_customers)
  ) 
  customers <- rowid_to_column(tb, "customer_id") 
  usethis::use_data(customers)
}
