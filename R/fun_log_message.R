# log message function - writes log message to file

log_msg = function(msg) {
  line = paste(Sys.time(), msg, sep = ' ')
  write(line, file.path(prj, 'log'), append = TRUE)
  message(line)
}