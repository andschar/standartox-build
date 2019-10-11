#!/usr/bin/Rscript

# this is the main script that has to be sourced and timed on the platform
# time this script tp run every 2 months
# crontab:
# 00 22 * * * /home/scharmueller/Projects/run_build.sh

# setup -------------------------------------------------------------------
source('~/Projects/standartox-build/R/gn_setup.R', max.deparse.length = mdl)

# SCRIPT TO TEST ----------------------------------------------------------



# end ---------------------------------------------------------------------
source(file.path(src, 'gn_end.R'))

