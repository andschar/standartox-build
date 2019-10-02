#!/usr/bin/Rscript
prj = '/home/scharmueller/Projects/standartox-app/'
source(file.path(prj, 'setup.R'))

nodename = Sys.info()[4]
if(nodename == 'uwigis') {
  host = 'http://139.14.20.252'
} else {
  host = 'http://127.0.0.1'
}

pr = plumber::plumb('api.R')
pr$run(host = host, port = 8000)
