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

log_summary = function(x) {
  nam = names(x)[1]
  fl = paste0(nam, '.csv')
  message('Writing: ', fl)
  fwrite(x, file.path(prj, 'summary', fl))
}

# Source log --------------------------------------------------------------
# logs informtaion if script is sourced succesfully ( using source_chck() )
log_source  = function(msg) {
  write(msg, file.path(prj, 'source.log'), append = TRUE)
}
