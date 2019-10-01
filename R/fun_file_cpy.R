# function to copy files and create folders if needed
# TODO add to asmisc

file_cpy = function(files = NULL, to = NULL, overwrite_dir = TRUE, ...) {
  # remove folder
  unlink(to, recursive = TRUE)
  mkdirs(to)
  # paths
  from = files
  to2 = file.path(to, basename(files))
  # copy
  file.copy(from = from,
            to = to2,
            overwrite = TRUE)
}