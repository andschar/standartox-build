# setup script for etox-base

# packages ----------------------------------------------------------------
if (!require('pacman')) install.packages('pacman')

## install via CRAN
pacman::p_load(RCurl, stringr, R.utils,
               rvest, V8,
               readxl, data.table, RPostgreSQL, vegan, plyr,
               feather,
               ggplot2, ggrepel, cowplot,
               rgbif, webchem, taxize, countrycode)

## install via Github
pacman::p_load_gh(char = 'NIVANorge/chemspideR')

# pacman::p_update()

# switches ----------------------------------------------------------------
online = TRUE
online_db = TRUE
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
source(file.path(src, 'fun_scrape_phantomjs.R'))

# library dependencies ----------------------------------------------------
# libsodium - for JS module fs - fun_scrape_phantomjs.R
# phantomjs - headless browser - fun_scrape_phantomjs.R










