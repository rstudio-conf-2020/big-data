
toc <- function(file_path) {
  re <- readLines(file_path)
  has_title <- as.logical(lapply(re, function(x) substr(x, 1, 1) == "#"))
  only_titles <- re[has_title]
  titles <- trimws(gsub("#", "", only_titles))
  links <- trimws(gsub("`", "", titles))
  links <- tolower(links)
  links <- trimws(gsub(" ", "-", links))
  links <- trimws(gsub(",", "", links))
  toc_list <- lapply(
    seq_along(titles),
    function(x) {
      pad <- ifelse(substr(only_titles[x], 1, 2) == "##", "    - ", "  - ")
      paste0(pad, titles[x])
    }
  )
  paste0(paste(toc_list, collapse = "\n") , "\n")
}

#' @export
book_files <- function(book_path = system.file("workbook", package = "bigdataclass")) {
  book_dir <- dir(book_path)
  book_files <- book_dir[grepl("Rmd", book_dir)]
  book_files <- book_files[book_files != "index.Rmd"]
  file.path(book_path, book_files)
}

#' @export
bdc_outline <- function() {
  all_tocs <- lapply(book_files(), toc)
  all_tocs <- paste0(all_tocs, collapse  = "")
  cat(all_tocs)
}

get_libraries <- function(file_path) {
  re <- readLines(file_path)
  has_library <- grepl("library\\(", re)
  only_libs <- re[has_library]
  libs <-  gsub("library\\(", "", only_libs) 
  libs <-  gsub("\\)", "", libs) 
  libs <- trimws(libs)
  unique(libs)
}

#' @export
bdc_libraries <- function(book_path = book_files()) {
  lib_list <- lapply(book_path, get_libraries)
  lib_list <- Reduce(c, lib_list)
  unique(lib_list)
}

install_command <- function() {
  all_libs <- paste0("\"", library_list(), "\"", collapse = ", ")
  cat(paste0("install.packages(c(", all_libs,"))"))
}
