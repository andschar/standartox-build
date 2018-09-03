# working directory (especially for shiny)
# TODO find a solution for shin!!

#rm(list = ls())
# switches
online = FALSE
if (online) {
  check = menu(c('yes', 'no'), title = 'Do you want to query all online databases?')
  if (check != 1) {
    stop('Change online setting.')
  } 
}

local = FALSE # have you built the EPA ECOTOX DB locally?
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
fundir = file.path(prj, 'functions')
plotdir = file.path(prj, 'plots')
srcdir = file.path(prj, 'R')
datadir = file.path(prj, 'data')
missingdir = file.path(prj, 'missing')
lookupdir = file.path(prj, 'lookup')

# source
source(file.path(srcdir, 'credentials.R')) # data base credentials
source(file.path(fundir, 'casconv.R')) # convert between CAS and CASNR
source(file.path(srcdir, 'gg_theme.R'))

# system calls
system('rm missing/*')


