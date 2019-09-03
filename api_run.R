#!/usr/bin/Rscript

source('setup.R')

pr = plumber::plumb('api.R')
pr$run(port = 8000)
