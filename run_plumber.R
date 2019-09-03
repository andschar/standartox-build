#!/usr/bin/Rscript

source('setup.R')

pr = plumber::plumb('R/functions/fun_filter_plumber.R')
pr$run(port = 80)
