# log warning message function

log_warn = function(warn) {
  time = Sys.time()
  script = basename(sys.frame(1)$ofile)
  out = paste(paste(time, script, 'run: ', sep = ' '),
              msg,
              sep = '\t')
  
  write(out, file.path(prj, 'warn.log'), append = TRUE)
  message(out)
}
