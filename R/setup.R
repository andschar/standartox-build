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
require(data.table)
require(RPostgreSQL)
require(ggplot2)
require(ggrepel)
require(vegan)
require(rgbif)
require(raster)

# data bases
require(rgbif)
require(taxize)
require(taxizesoap)
require(countrycode)

# installation of taxizesoap: https://github.com/ropensci/taxizesoap
# install.packages(c("XMLSchema", "SSOAP"), repos = c("http://packages.ropensci.org", "http://cran.rstudio.com"))
# devtools::install_github("ropensci/taxizesoap")
require(webchem)

# variables
cachedir = '/home/andreas/Documents/Projects/etox-base/cache'
fundir = '/home/andreas/Documents/Projects/etox-base/functions'
plotdir = '/home/andreas/Documents/Projects/etox-base/plots'
srcdir = '/home/andreas/Documents/Projects/etox-base/R'
datadir = '/home/andreas/Documents/Projects/etox-base/data'


# source
source('/home/andreas/Documents/cred/DB_access.R') # data base credentials
# source(file.path(fundir, 'ppdb-0-0-5.R'))
# source(file.path(fundir, 'ppdb_own_functions.R'))
source(file.path(fundir, 'casconv.R')) # convert between CAS and CASNR
# source(file.path(fundir, 'functions.R')) # contains gm_mean(), ksource()
# source(file.path(fundir, 'agg_group.R'))
# source(file.path(fundir, 'plot_outlier.R'))





