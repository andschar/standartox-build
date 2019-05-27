# log message function - writes log message to file

log_msg = function(msg) {
  script = basename(sys.frame(1)$ofile)
  out = paste(paste(Sys.time(), script, 'run: ', sep = ' '),
              msg,
              sep = '\t')
  write(out, file.path(prj, 'script.log'), append = TRUE)
  message(out)
}

log_chck = function(msg) {
  script = basename(sys.frame(1)$ofile)
  out = paste(paste(Sys.time(), script, 'run: ', sep = ' '),
              msg,
              sep = '\t')
  write(out, file.path(prj, 'chck.log'), append = TRUE)
  message(out)
}