#!/usr/bin/Rscript

# this is the main script that has to be sourced and timed on the platform
# time this script tp run every 2 months
# crontab:
# 00 22 * * * /home/scharmueller/Projects/run_build.sh

# setup -------------------------------------------------------------------
source('~/Projects/standartox-build/R/gn_setup.R', max.deparse.length = mdl)

# console log -------------------------------------------------------------
if (sink_console) {
  con = file(file.path(prj, 'console.log'))
  sink(con, append = TRUE)
  sink(con, append = TRUE, type = 'message')
}


# SCRIPT TO TEST ----------------------------------------------------------



# end ---------------------------------------------------------------------
source(file.path(src, 'gn_end.R'))

# # (0b) console log 2 --------------------------------------------------------
if (sink_console) {
  # Restore output to console
  sink()
  sink(type="message")
}
