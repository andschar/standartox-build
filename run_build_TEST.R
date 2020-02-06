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
source(file.path(src, 'rep_query_prep.R'), max.deparse.length = mdl)
# source(file.path(src, 'qu_taxa_fin.R'), max.deparse.length = mdl) # TODO error  GREATEST(wo.brack, epa_habi.brackish)::boolean AS brack
source(file.path(src, 'qu_phch_fin.R'), max.deparse.length = mdl)
source(file.path(src, 'bd_standartox.R'), max.deparse.length = mdl)
source(file.path(src, 'rep_standartox.R'), max.deparse.length = mdl)
source(file.path(src, 'exp_standartox2.R'), max.deparse.length = mdl)
source(file.path(src, 'exp_standartox_catalog.R'), max.deparse.length = mdl)

# end ---------------------------------------------------------------------
source(file.path(src, 'gn_end.R'), max.deparse.length = mdl)

# console log 2 -----------------------------------------------------------
if (sink_console) {
  # Restore output to console
  sink()
  sink(type = "message")
}


