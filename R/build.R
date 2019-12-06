#' @export
bdc_build_workbook <- function(stage_folder = tempdir(), 
                           source = system.file("workbook", package = "bigdataclass"),
                           db_folder = "database",
                           file_folder = "files", 
                           book_folder = "books"
                           ) {
  if(!dir.exists(stage_folder)) dir.create(stage_folder)
  file.copy(source, stage_folder, recursive = TRUE, overwrite = TRUE)
  wb_path <- file.path(stage_folder, "workbook")
  file.copy(db_folder, wb_path, recursive = TRUE)
  file.copy(file_folder, wb_path, recursive = TRUE)
  file.copy(book_folder, wb_path, recursive = TRUE)
  bookdown::serve_book(wb_path)
}

build_book <- function() {
  setwd(here::here("assets/workbook"))
  #Sys.setenv(GLOBAL_EVAL = TRUE)
  files <- c(
    "derby.log",
    "parsedmodel.csv",
    "_bookdown_files",
    "_main.Rmd",
    "saved_model",
    "saved_pipeline",
    "new_model",
    "logs",
    "_book",
    "my_model.yml",
    "mydatabase.sqlite",
    list.files(pattern = "\\.md"),
    list.files(pattern = "\\.rds")
  )
  unlink(files, recursive = TRUE, force = TRUE)
  copy_data <- function() {
    unlink("data", recursive = TRUE, force = TRUE)
    dir.create("data")
    file.copy("../../data", ".", recursive = TRUE)
    # Books for the text mining unit
    unlink("books", recursive = TRUE, force = TRUE)
    dir.create("books")
    file.copy("../../books", ".", recursive = TRUE)
    # Books for the text mining unit
    unlink("books", recursive = TRUE, force = TRUE)
    dir.create("books")
    file.copy("../../books", ".", recursive = TRUE)
    # Database
    unlink("database", recursive = TRUE, force = TRUE)
    dir.create("database")
    file.copy("../../database", ".", recursive = TRUE)
  }
  copy_data()
  bookdown::serve_book()
  .rs.removeAllObjects(TRUE, globalenv())
  .rs.restartR(
    afterRestartCommand = "browseURL('_book/index.html'); setwd(here::here())"
  )
}

