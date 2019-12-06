#' @export
bdc_setup_database <- function(con,
                               avg_daily_orders = 100,
                               avg_no_items = 3,
                               days_in_segment = 10,
                               no_of_segments = 100,
                               seed = 7878,
                               product_data = bdc_create_products(), 
                               customer_data = bigdataclass::customers,
                               start_date = "2016-01-01",
                               orders_view = "v_orders"
                               ) {
  print("Creating product and customer tables")
  bdc_db_lookups(
    con = con, 
    product_data = product_data, 
    customer_data = customer_data
  )
  print("Creating orders and line items tables")
  bdc_db_orders(
    con = con,
    avg_daily_orders = avg_daily_orders,
    avg_no_items = avg_no_items,
    days_in_segment = days_in_segment,
    no_of_segments = no_of_segments,
    seed = seed
  )
  print("Creating date table")
  bdc_db_create_dates(
    con = con, 
    start_date = start_date
    )
  print("Creating view")
  bdc_create_view_orders(
    con = con, 
    name = orders_view
    )
}