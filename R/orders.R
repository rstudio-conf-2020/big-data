#' @export
bdc_db_orders <- function(con,
                          avg_daily_orders = 100,
                          avg_no_items = 3,
                          days_in_segment = 10,
                          no_of_segments = 100,
                          seed = 7878
) {
  UseMethod("bdc_db_orders")
}

#' @export
bdc_db_orders.connConnection <- function(con,
                                         avg_daily_orders = 100,
                                         avg_no_items = 3,
                                         days_in_segment = 10,
                                         no_of_segments = 100,
                                         seed = 7878
                                         ) { 
  bdc_db_orders(
    con@con,
    avg_daily_orders = avg_daily_orders,
    avg_no_items = avg_no_items,
    days_in_segment = days_in_segment,
    no_of_segments = no_of_segments,
    seed = seed   
  )
}

bdc_db_orders.SQLiteConnection <- function(con, 
                                           avg_daily_orders = 100,
                                           avg_no_items = 3,
                                           days_in_segment = 10,
                                           no_of_segments = 100,
                                           seed = 7878
                                           ) {
  set.seed(seed)
  no_customers <- tbl(con, "customer") %>% count() %>% pull()
  no_products <- tbl(con, "product") %>% count() %>% pull()
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
    order_count <- sample(
      length(order_probs), 
      size = day_size, 
      replace = TRUE, 
      prob = order_probs
    )
    order_size <- sum(order_count)
    order_id <- seq_along(order_count) %>%
      map(~rep(.x, times = order_count[.x])) %>%
      reduce(c)
    
    customer_probs <- sample(100, size = no_customers) / 100
    customer_count <- sample(
      no_customers, 
      size = day_size, 
      replace = TRUE, 
      prob = customer_probs 
    )
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
    
    orders <- transactions %>%
      group_by(order_id, customer_id, step_id) %>%
      summarise() %>%
      ungroup()
    
    line_items <- transactions %>%
      select(-customer_id, -step_id, -transaction_id)
    
    if(i == 1) {
      dbWriteTable(con, "order", orders, overwrite = TRUE)
      dbWriteTable(con, "line_item", line_items, overwrite = TRUE)
    } else {
      dbWriteTable(con, "order", orders, append = TRUE)
      dbWriteTable(con, "line_item", line_items, append = TRUE)
    }
    print(paste0(i, " of ", no_of_segments, " complete- From: ", from, " - to: ", to))
  }
}
