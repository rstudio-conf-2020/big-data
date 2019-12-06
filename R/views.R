#' @export
bdc_create_view <- function(query, name) {
  UseMethod("bdc_create_view")
}

#' @export
bdc_create_view.tbl_SQLiteConnection <- function(query, name) {
  sql_query <- remote_query(query)
  full_sql <- glue_sql("CREATE VIEW ", name, " AS ", sql_query)
  con_sql <- remote_con(query)
  rs <- dbSendQuery(con_sql, full_sql)
  dbClearResult(rs)
}

#' @export
bdc_create_view_orders <- function(con, name = "v_orders") {
  qry <- tbl(con, "order") %>%
    inner_join(tbl(con, "date"), by = "step_id") %>%
    inner_join(tbl(con, "customer"), by = "customer_id") %>%
    inner_join(tbl(con, "line_item"), by = "order_id") %>%
    inner_join(tbl(con, "product"), by = "product_id") %>%
    group_by(
      order_id, date, date_year,
      date_month, customer_id, customer_name,
      customer_lon, customer_lat
    ) %>%
    summarise(order_total = sum(price, na.rm = TRUE), order_qty = n())
  bdc_create_view(query = qry, name = name)
}

#' @export
bdc_create_view_lineitems <- function(con, name = "v_lineitems") {
  qry <- tbl(con, "order") %>%
    inner_join(tbl(con, "date"), by = "step_id") %>%
    inner_join(tbl(con, "customer"), by = "customer_id") %>%
    inner_join(tbl(con, "line_item"), by = "order_id") %>%
    inner_join(tbl(con, "product"), by = "product_id") %>%
    select(order_id, contains("order_date"), contains("customer_"), everything()) %>%
    select(-step_id)
  bdc_create_view(query = qry, name = name)
}
