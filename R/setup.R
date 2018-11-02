# setup script for etox-base

# packages ----------------------------------------------------------------
if (!require('pacman')) install.packages('pacman')

## install via CRAN
pacman::p_load(RCurl, stringr, R.utils,
               rvest, httr, jsonlite,
               readxl, data.table, RPostgreSQL, vegan, plyr, outliers,
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
full_gbif_l = FALSE # loads the full result list if online=FALSE (big!)
debug_mode = FALSE # should only 10 input rows for each quering script be run

# variables ---------------------------------------------------------------
cachedir = file.path(prj, 'cache')
missingdir = file.path(prj, 'missing')
fundir = file.path(prj, 'functions')
plotdir = file.path(prj, 'plots')
src = file.path(prj, 'R')
datadir = file.path(prj, 'data')
lookupdir = file.path(prj, 'lookup')
shinydata = file.path(shinydir, 'data')
cred = file.path(prj, 'cred')
share = file.path(prj, 'share')

# path to phantomjs
if (nodename == 'scharmueller') {
  phantompath = '/usr/bin/phantomjs'
} else if (nodename == 'uwigis') {
  phantompath = '/usr/local/share/phantomjs-2.1.1-linux-x86_64/bin/phantomjs'
}

# source ------------------------------------------------------------------
source(file.path(cred, 'credentials.R')) # data base credentials
source(file.path(fundir, 'casconv.R')) # convert between CAS and CASNR
source(file.path(src, 'fun_product_na.R'))
source(file.path(src, 'fun_extr_vec.R'))
source(file.path(src, 'fun_log_message.R'))
source(file.path(src, 'fun_scrape_phantomjs.R'))
source(file.path(src, 'fun_worms_query.R'))

# database ----------------------------------------------------------------
# put database credentials here?

# library dependencies ----------------------------------------------------
# libsodium - for JS module fs - fun_scrape_phantomjs.R
# phantomjs - headless browser - fun_scrape_phantomjs.R
# libv8-3.14-dev - Google's open source JavaScript engine - fun_scrape_phantomjs.R









