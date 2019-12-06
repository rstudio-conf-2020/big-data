#' @import charlatan
#' @import gutenbergr
#' @import dplyr
#' @import DBI
#' @import bookdown
#' @import progress
#' @import usethis
#' @importFrom tibble rowid_to_column
#' @importFrom tibble tibble
#' @importFrom readr write_rds
#' @importFrom magrittr %>%
#' @importFrom purrr map
#' @importFrom purrr reduce
#' @importFrom glue glue_sql
#' @importFrom dbplyr remote_query
#' @importFrom dbplyr remote_con
#' @importFrom graphics text
#' @importFrom stats rpois
#' @importFrom stats runif
#' @importFrom utils head
#' @keywords internal
NULL
gv <- c("order_id", "step_id", "order_id", "date_year", "date_month", "customer_id", "customer_name", 
        "customer_lon", "customer_lat", "step_id", "transaction_id", "library_list", "author", "gutenberg_id", 
        "price")
utils::globalVariables(gv)


