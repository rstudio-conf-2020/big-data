#' @param folder Folder location to place the database file
#' @export
bdc_init_sqlite <- function(folder = "database") {
  path <- file.path(folder, "local.sqlite")
  if (file.exists(path)) unlink(path)
  if (!dir.exists(folder)) dir.create(folder)
  dbConnect(RSQLite::SQLite(), path)
}

#' @export
bdc_init_database <- function(con,
                              avg_daily_orders = 100,
                              avg_no_items = 3,
                              days_in_segment = 10,
                              no_of_segments = 100,
                              seed = 7878,
                              product_data = bdc_create_products(),
                              customer_data = bigdataclass::customers,
                              start_date = "2016-01-01",
                              orders_view = "v_orders",
                              lineitems_view = "v_lineitems") {
  ui_info("Creating product and customer tables")
  bdc_db_lookups(
    con = con,
    product_data = product_data,
    customer_data = customer_data
  )
  ui_done("Product table created")
  ui_done("Customer table created")
  ui_info("Creating order and line item tables")
  bdc_db_orders(
    con = con,
    avg_daily_orders = avg_daily_orders,
    avg_no_items = avg_no_items,
    days_in_segment = days_in_segment,
    no_of_segments = no_of_segments,
    seed = seed
  )
  ui_done("Orders table created")
  ui_done("Line items table created")
  bdc_db_create_dates(
    con = con,
    start_date = start_date
  )
  ui_done("Date table created")
  bdc_create_view_orders(
    con = con,
    name = orders_view
  )
  ui_done("Orders view created")
  bdc_create_view_lineitems(
    con = con,
    name = lineitems_view
  )
  ui_done("Line items view created")
}
