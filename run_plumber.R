#!/usr/bin/Rscript

pr = plumber::plumb('myfile.R')
pr$run(port = 80)
