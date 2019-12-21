# functions to convert strings from and to filenames

to_filename = function(x, format = '.rds') {
  paste0(gsub('\\s+', '_', x), format)
}

from_filename = function(x) {
  trimws(gsub('(.+)(\\..+)', '\\1', gsub('_', ' ', x)))
}