# log message function - writes log message to file

log_msg = function(msg) {
  time = Sys.time()
  script = basename(sys.frame(1)$ofile)
  out = paste(paste(time, script, 'run: ', sep = ' '),
              msg,
              sep = '\t')
  
  write(out, file.path(prj, 'script.log'), append = TRUE)
  message(out)
}
