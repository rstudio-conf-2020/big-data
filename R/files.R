db_create_file <- function(con, transactions_path, no_transactions, batch_size, no_files) {
  lineitems <- tbl(con, "v_lineitems") 
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
      day_trans <- lineitems %>%
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