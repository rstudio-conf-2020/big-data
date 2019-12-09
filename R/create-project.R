#' Creates a new RStudio project with the exercises 
#' @param folder Path to folder where to build the project
#' @param src Path to the source folder of the exercises
#' @param overwrite Overwrite class folder if it exists
#' @param db_connection Text code for connecting to the database
#' @param files_path Location of the files folder
#' @param books_path Location of the books folder
#' @export
bdc_create_project <- function(folder = "big-data-class", 
                               src = system.file("exercises", package = "bigdataclass"),
                               overwrite = FALSE,
                               db_connection = "con <- connection_open(RSQLite::SQLite(), 'database/local.sqlite')",
                               dbi_connection = "con <- dbConnect(RSQLite::SQLite(), 'database/local.sqlite')",
                               files_path = "files",
                               books_path = "books"
                               ) {
  if (dir.exists(folder)) {
    if(overwrite) {
      unlink(folder, recursive = TRUE, force = TRUE)    
    } else {
      stop(paste0("The '", basename(folder), "'  already exists, use overwrite = TRUE to replace its contents"))
    }
  }
  dir.create(folder)  
  unlink(folder, recursive = TRUE, force = TRUE)
  if (!dir.exists(folder)) dir.create(folder)
  file.copy(
    file.path(src, list.files(src)),
    folder,
    overwrite = TRUE
  )
  proj_template <- system.file("templates/template.Rproj", package = "usethis")
  file.copy(proj_template, folder)
  file.rename(
    file.path(folder, "template.Rproj"),
    file.path(folder, "bigdataclass.Rproj")
  )
  tag_replace(folder, "files", files_path)
  tag_replace(folder, "books", books_path)
  tag_replace(folder, "db_connection", db_connection)
  tag_replace(folder, "dbi_connection", dbi_connection)
}

tag_replace <- function(folder = "big-data-class",
                        tag = "files",
                        value = "/usr/shared/class/files"
                        ) {
  book_dir <- dir(folder)
  book_files <- book_dir[grepl("Rmd", book_dir)]
  book_files <- book_files[book_files != "index.Rmd"]
  book_files <- file.path(folder, book_files)
  lapply(book_files, text_replace, tag, value)
}

text_replace <- function(file_path, tag, value) {
  curr_file <- readLines(file_path)
  new_file <- sub(paste0("\\{\\{", tag,"\\}\\}"), value, curr_file)
  writeLines(new_file, file_path)
}
