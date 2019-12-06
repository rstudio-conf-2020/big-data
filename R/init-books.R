#' Creates and populates the 'books' folder
#' @param folder Defaults to 'books'
#' @export
bdc_init_books <- function(folder = "books") {
  if (!dir.exists(folder)) dir.create(folder)
  all_works <- gutenbergr::gutenberg_metadata
  write_book(
    all_works,
    "Doyle, Arthur Conan",
    file.path(folder, "arthur_doyle.txt")
  )
  write_book(
    all_works,
    "Twain, Mark",
    file.path(folder, "mark_twain.txt")
  )
}

write_book <- function(works, name, path) {
  works %>%
    filter(author == name) %>%
    pull(gutenberg_id) %>%
    gutenberg_download() %>%
    pull(text) %>%
    writeLines(path)
}
