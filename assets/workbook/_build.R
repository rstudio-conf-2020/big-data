setwd(file.path(here::here(), "assets/workbook"))
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
  file.copy("../../assets/setup/database", ".", recursive = TRUE)
}
#copy_data()
bookdown::serve_book()
.rs.removeAllObjects(TRUE, globalenv())
.rs.restartR(
  afterRestartCommand = "browseURL('_book/index.html'); setwd(file.path(here::here()))"
  )
