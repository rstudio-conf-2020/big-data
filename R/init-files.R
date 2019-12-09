#' Initializes the files based on a database connection
#' @param con Database connection
#' @param folder Folder path where to create the files
#' @param no_transactions Number of transactions to save to file
#' @param batch_size File batch size
#' @param no_files Number of files
#' @export
bdc_init_files <- function(con, 
                           folder = "files",
                           no_transactions = 50000,
                           batch_size = 5000,
                           no_files = 5
                           ) {
  if (!dir.exists(folder)) dir.create(folder)
  lineitems <- tbl(con, "v_lineitems")
  csv_files <- list.files(folder, "*.csv")
  unlink(file.path(folder, csv_files))
  max_batch <- 0
  ui_info("Create data files")
  for (j in seq_len(no_files)) {
    file_batch <- (j - 1) * no_transactions
    total_segments <- no_transactions / batch_size
    for (i in seq_len(total_segments)) {
      file_path <- file.path(folder, paste0("transactions_", j, ".csv"))
      day_trans <- lineitems %>%
        filter(order_id > max_batch) %>%
        arrange(order_id) %>%
        head(batch_size) %>%
        collect()
      max_batch <- max(day_trans$order_id)
      min_batch <- min(day_trans$order_id)
      if (i == 1) {
        vroom::vroom_write(day_trans, file_path, ",")
      }
      else {
        vroom::vroom_write(day_trans, file_path, ",", append = TRUE)
      }
    }
    ui_done(paste0("Data file: ", j, " of ", no_files, " ---"))
  }
}
