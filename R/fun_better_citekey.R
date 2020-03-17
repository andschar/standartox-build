# function to create citekey from a vector of package names
# TODO add functionality to get authors, titles etc. in a data.frame back
# TODO add functionality to allow user-specific kex concatentation

#' Helper function
#'
clean_space = function(x) {
  trimws(gsub('\\s+', ' ', x))
}


better_citekey = function(pkg_l = NULL) {
  if (is.null(pkg_l)) {
    stop('Provide a .bib file.')
  }
  foo = function(pkg) {
    vec = trimws(capture.output(
      print(citation(pkg)[1], style = 'bibtex') # NOTE citation(pkg) is actually a list, [1] refers to 1st element, which usually shoulb bd @Manual
      # NOTE utils::cit* functions are really confusing, a maze
    ))
    # extract
    title = str_extract(
      gsub(
        'title.+=.+\\{', '',
        grep('title', vec, value = TRUE)),
      '[A-z]+'
    )
    description = strsplit(
      grep('title', vec, value = TRUE), ':'
    )[[1]][2]
    year = str_extract(
      grep('year', vec, value = TRUE), '[0-9]+')
    author = strsplit(
      gsub('.+author.+=.+\\{', '',
           grep('author', vec, value = TRUE)), 'and')[[1]][[1]]
    # clean
    author = clean_space(gsub('\\W', ' ', author))
    title = clean_space(gsub('\\W', ' ', title))
    description = clean_space(gsub('\\W', ' ', description))
    year = clean_space(gsub('\\W', '', year))
    # concatenate
    author = tolower(gsub('([A-z]).+([A-Z]+)', '\\2', author))
    # citekey
    citekey = paste(tolower(author),
                    tolower(title),
                    tolower(year),
                    sep = '_')
    # fin
    data.frame(citekey = citekey,
               author = author,
               title = title,
               description = description,
               year = year,
               stringsAsFactors = FALSE)
  }
  l = lapply(pkg_l, foo)
  do.call(rbind, l)
}
