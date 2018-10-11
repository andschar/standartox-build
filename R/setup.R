# setup script for etox-base

# packages ----------------------------------------------------------------
if (!require('pacman')) install.packages('pacman')

pacman::p_load(readxl, data.table, RPostgreSQL, vegan, plyr,
               ggplot2, ggrepel, cowplot,
               rgbif, webchem, taxize, countrycode)

pacman::p_update()

#### Notes:
# TODO not used currently
# TODO p_load(raster) ??? why raster ???
# installation of taxizesoap: https://github.com/ropensci/taxizesoap
# install.packages(c("XMLSchema", "SSOAP"), repos = c("http://packages.ropensci.org", "http://cran.rstudio.com"))
# devtools::install_github("ropensci/taxizesoap")


# switches ----------------------------------------------------------------
src_ECOTOX = FALSE
online = FALSE
online_db = FALSE
plots = FALSE

# variables ---------------------------------------------------------------
cachedir = file.path(prj, 'cache')
missingdir = file.path(cachedir, 'missing')
fundir = file.path(prj, 'functions')
plotdir = file.path(prj, 'plots')
src = file.path(prj, 'R')
datadir = file.path(prj, 'data')
lookupdir = file.path(prj, 'lookup')
cred = file.path(prj, 'cred')

# source ------------------------------------------------------------------
source(file.path(cred, 'credentials.R')) # data base credentials
source(file.path(fundir, 'casconv.R')) # convert between CAS and CASNR
source(file.path(src, 'gg_theme.R'))


