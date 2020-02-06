# convenience wraper for readChar

read_char = function(file = NULL) {
  if (is.null(file))
    stop('No file provided.')
  q = readChar(file, file.info(file)$size)
}