# log message function - writes log message to file

log_msg = function(msg) {
  # script = basename(sys.frame(1)$ofile)
  # out = paste(paste(Sys.time(), script, 'run: ', sep = ' '),
  #             msg,
  #             sep = '\t')
  out = msg
  write(out, file.path(prj, 'script.log'), append = TRUE)
  message(out)
}
