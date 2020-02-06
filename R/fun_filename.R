# functions to convert strings from and to filenames

to_filename = function(x, format = '.rds') {
  paste0(gsub('\\s+', '_', x), format)
}

from_filename = function(x) {
  trimws(gsub('(.+)(\\..+)', '\\1', gsub('_', ' ', x)))
}

# TODO maybe an improvment for the future
# write_cache = function(obj, name) {
#   
#   
#   paste0(gsub('\\s+', '_', x), format)
#   saveRDS(gbif, file.path(cachedir, 'gbif', to_filename(nam, format = '.rds')))  
#   
# }