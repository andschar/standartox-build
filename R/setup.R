# setup script for etox-base

# packages ----------------------------------------------------------------
if (!require('pacman')) {
  install.packages('pacman')
}

pkg_cran = c(
  'base', # only for citation
  'devtools',
  'RCurl',
  'stringr',
  'R.utils',
  'udunits2',
  'rvest',
  'httr',
  'jsonlite',
  'readxl',
  'openxlsx',
  'purrr',
  'data.table',
  'RPostgreSQL',
  'vegan',
  'plyr',
  'outliers',
  'feather',
  'ggplot2',
  'ggrepel',
  'cowplot',
  'rgbif',
  'taxize',
  'countrycode',
  'foreach',
  'doParallel'
)
pkg_gith = c('ropensci/bib2df', 'webchem') # , 'NIVANorge/chemspideR') # no citation available!

## install via CRAN
pacman::p_load(char = pkg_cran)

## install via Github
pacman::p_load_gh(char = pkg_gith)

# pacman::p_update()

# switches ----------------------------------------------------------------
online = FALSE # should queries be run
online_db = FALSE # should database query be run
build = FALSE # should data base be rebuilt
plots = FALSE # should output plots be created
scp_feather = FALSE # scp feather object # TODO remove this in the end
full_gbif_l = FALSE # loads the full result list if online=FALSE (big!)
# debuging
debug_mode = TRUE # should only 10 input rows for each quering script be run
sink_console = TRUE # sink console to file

# variables ---------------------------------------------------------------
cachedir = file.path(prj, 'cache')
missingdir = file.path(prj, 'missing')
meta = file.path(prj, 'meta')
fundir = file.path(prj, 'functions')
plotdir = file.path(prj, 'plots')
src = file.path(prj, 'R')
data = file.path(prj, 'data')
data_ecotox = file.path(data, 'ecotox')
data_chebi = file.path(data, 'chebi')
lookupdir = file.path(prj, 'lookup')
shinydir = paste0(prj, '-shiny')
shinydata = file.path(shinydir, 'data')
cred = file.path(prj, 'cred')
share = file.path(prj, 'share')
normandir = file.path(prj, 'norman')
sql = file.path(prj, 'sql')
# article
article = file.path(prj, 'article')
datadir_ar = file.path(article, 'data')

# data base to write to
if (debug_mode) {
  DBetox = 'testdb'
} else {
  DBetox = try(readRDS(file.path(cachedir, 'data_base_name_version.rds')))
  if(inherits(DBetox, 'try-error')) {
    DBetox = 'DBetox not yet defined'
  }
}

# path to phantomjs
if (nodename == 'scharmueller-t460s') {
  phantompath = '/usr/local/bin/phantomjs'
} else if (nodename == 'uwigis') {
  phantompath = '/usr/local/share/phantomjs-2.1.1-linux-x86_64/bin/phantomjs'
} else {
  stop('No nodename matches.')
}

# other
mdl = 1e6 # max deparse length for writing to sink console

# source ------------------------------------------------------------------
source(file.path(cred, 'credentials.R')) # data base credentials
source(file.path(fundir, 'casconv.R')) # convert between CAS and CASNR
source(file.path(src, 'fun_clean_workspace.R'))
source(file.path(src, 'fun_write_db.R'))
source(file.path(src, 'fun_product_na.R'))
source(file.path(src, 'fun_extr_vec.R'))
source(file.path(src, 'fun_log_message.R'))
source(file.path(src, 'fun_scrape_phantomjs.R'))
source(file.path(src, 'fun_worms_query.R'))
source(file.path(src, 'fun_ln_na.R'))
source(file.path(src, 'fun_paste2.R'))
source(file.path(src, 'fun_norman.R'))
source(file.path(src, 'fun_shiny_variables_stat.R'))
source(file.path(src, 'fun_udunits2_vectorize.R'))
source(file.path(src, 'fun_coalesce.R'))
source(file.path(src, 'fun_clean_names.R'))
source(file.path(src, 'fun_chck_dupl.R'))

# database ----------------------------------------------------------------
fl = file.path(cred, 'chemspider_apikey.txt')
csapikey = readChar(fl, file.info(fl)$size)

# library dependencies ----------------------------------------------------
# libsodium - for JS module fs - fun_scrape_phantomjs.R
# phantomjs - headless browser - fun_scrape_phantomjs.R
# libv8-3.14-dev - Google's open source JavaScript engine - fun_scrape_phantomjs.R

# cite packages -----------------------------------------------------------
pkg = c('pacman', pkg_cran)

for (i in pkg) {
  capture.output(
    utils:::print.bibentry(citation(i), style = "Bibtex"),
    file = file.path(article, 'refs', 'references-etox-base-rpackages.bib'),
    append = TRUE
  )
}




