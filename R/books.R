create_doyle_twain <- function(path = "books") {
  if(!dir.exists(path)) dir.create(path)
  gutenberg_works()  %>%
    filter(author == "Doyle, Arthur Conan") %>%
    pull(gutenberg_id) %>%
    gutenberg_download() %>%
    pull(text) %>%
    writeLines(file.path(path, "arthur_doyle.txt"))
  
  gutenberg_works()  %>%
    filter(author == "Twain, Mark") %>%
    pull(gutenberg_id) %>%
    gutenberg_download() %>%
    pull(text) %>%
    writeLines(file.path(path, "mark_twain.txt"))
}