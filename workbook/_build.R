setwd(here::here("workbook"))
Sys.setenv(GLOBAL_EVAL = TRUE)
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
  "spark-warehouse",
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
#copy_data()
bookdown::serve_book(output_dir = here::here("docs"))
.rs.removeAllObjects(TRUE, globalenv())
.rs.restartR(
  afterRestartCommand = "setwd(here::here()); browseURL('docs/index.html')"
)
