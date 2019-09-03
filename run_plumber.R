#!/usr/bin/Rscript

source('setup.R')

pr = plumber::plumb('myfile.R')
pr$run(port = 80)
