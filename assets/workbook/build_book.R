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
  list.files(pattern = "\\.md"),
  list.files(pattern = "\\.rds")
)
unlink(files, recursive = TRUE, force = TRUE)
bookdown::serve_book()
.rs.removeAllObjects(TRUE, globalenv())
.rs.restartR()