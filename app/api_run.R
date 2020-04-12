#!/usr/bin/Rscript

nodename = Sys.info()[4]
if(nodename == 'uwigis') {
  host = '139.14.20.252'
} else {
  host = '127.0.0.1'
}

pr = plumber::plumb('~/Projects/standartox-build/app/api.R')
pr$run(host = host, port = 8000)
