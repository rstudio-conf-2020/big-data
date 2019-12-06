#' @export
bdc_init_class_sqlite <- function(folder = "bigdataclass", 
                                  avg_daily_orders = 100,
                                  avg_no_items = 3,
                                  days_in_segment = 10,
                                  no_of_segments = 100,
                                  seed = 7878,
                                  product_data = bdc_create_products(), 
                                  customer_data = bigdataclass::customers,
                                  start_date = "2016-01-01",
                                  no_transactions = 50000, 
                                  batch_size = 5000, 
                                  no_files = 5
                                  ) {
  unlink(folder, recursive = TRUE, force = TRUE)
  if(!dir.exists(folder)) dir.create(folder)
  con <- bdc_init_sqlite(file.path(folder, "database"))
  bdc_init_database(con = con,
                    avg_daily_orders = avg_daily_orders,
                    avg_no_items = avg_no_items,
                    days_in_segment = days_in_segment,
                    no_of_segments = no_of_segments,
                    start_date = start_date,
                    seed = seed
                    )
  bdc_init_files(con = con,
                 no_transactions = no_transactions,
                 batch_size = batch_size,
                 no_files = no_files,
                 folder = file.path(folder, "files")
                 )
  # bdc_init_books(file.path(folder, "books"))
  ef <- system.file("exercises", package = "bigdataclass")
  file.copy(
    file.path(ef, list.files(ef)),
    folder,
    overwrite = TRUE
  )
  proj_template <- system.file("templates/template.Rproj", package = "usethis")
  file.copy(proj_template, folder)
  file.rename(
    file.path(folder, "template.Rproj"), 
    file.path(folder, "bigdataclass.Rproj")
  )
  proj_activate(folder)
}



