# working directory (especially for shiny)
# TODO find a solution for shin!!

#rm(list = ls())
# switches

src_ECOTOX = FALSE
online = FALSE
online_db = FALSE
plots = FALSE

# packages
require(readxl)
require(data.table)
require(RPostgreSQL)
require(vegan)
require(raster)

# ploting
require(ggplot2)
require(ggrepel)
require(cowplot)

# data bases
require(rgbif)
require(taxize)
require(taxizesoap)
require(countrycode)

# installation of taxizesoap: https://github.com/ropensci/taxizesoap
# install.packages(c("XMLSchema", "SSOAP"), repos = c("http://packages.ropensci.org", "http://cran.rstudio.com"))
# devtools::install_github("ropensci/taxizesoap")
require(webchem)

# project path
prj = '/home/andreas/Documents/Projects/etox-base' #! change to your project directory here!

# variables
cachedir = file.path(prj, 'cache')
missingdir = file.path(cachedir, 'missing')
fundir = file.path(prj, 'functions')
plotdir = file.path(prj, 'plots')
src = file.path(prj, 'R')
datadir = file.path(prj, 'data')
lookupdir = file.path(prj, 'lookup')
shinydir = file.path(prj, 'shiny')

# source
source(file.path(src, 'credentials.R')) # data base credentials
source(file.path(fundir, 'casconv.R')) # convert between CAS and CASNR
source(file.path(src, 'gg_theme.R'))

# system calls
system(sprintf('rm %s/*', missingdir))


