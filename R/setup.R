# setup script for etox-base

# packages ----------------------------------------------------------------
if (!require('pacman')) install.packages('pacman')

pacman::p_load(RCurl, stringr,
               readxl, data.table, RPostgreSQL, vegan, plyr,
               ggplot2, ggrepel, cowplot,
               rgbif, webchem, taxize, countrycode)

# pacman::p_update()

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
source(file.path(src, 'gg_theme.R'))


