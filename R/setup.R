# setup script for etox-base

# packages ----------------------------------------------------------------
if (!require('pacman')) install.packages('pacman')

## install via CRAN
pacman::p_load(RCurl, stringr, R.utils,
               readxl, data.table, RPostgreSQL, vegan, plyr,
               feather,
               ggplot2, ggrepel, cowplot,
               rgbif, webchem, taxize, countrycode)

## install via Github
pacman::p_load_gh('NIVANorge/chemspideR')

# pacman::p_update()

# switches ----------------------------------------------------------------
online = FALSE
online_db = FALSE
plots = FALSE
scp_feather = FALSE

# variables ---------------------------------------------------------------
cachedir = file.path(prj, 'cache')
missingdir = file.path(prj, 'missing')
fundir = file.path(prj, 'functions')
plotdir = file.path(prj, 'plots')
src = file.path(prj, 'R')
datadir = file.path(prj, 'data')
lookupdir = file.path(prj, 'lookup')
cred = file.path(prj, 'cred')

# source ------------------------------------------------------------------
source(file.path(cred, 'credentials.R')) # data base credentials
source(file.path(fundir, 'casconv.R')) # convert between CAS and CASNR
source(file.path(src, 'fun_product_na.R'))
source(file.path(src, 'fun_extr_vec.R'))
source(file.path(src, 'fun_log_message.R'))


