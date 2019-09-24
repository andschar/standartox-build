# setup script for etox-base

# projects ----------------------------------------------------------------
nodename = Sys.info()[4]
if (nodename == 'scharmueller-t460s') {
  prj = '/home/scharmueller/Projects/etox-base'
} else if (nodename == 'uwigis') {
  prj = '/home/scharmueller/Projects/etox-base'
} else {
  stop('New system. Define prj variable.')
}

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
  'DBI',
  'vegan',
  'plyr',
  'outliers',
  'feather',
  'ggplot2',
  'ggrepel',
  'cowplot',
  'RColorBrewer',
  'treemap',
  'rgbif',
  'taxize',
  'countrycode',
  'foreach',
  'doParallel',
  'fst',
  'DT',
  'treemap'
  # TODO check if all packages are still needed!
)
pkg_gith = c('ropensci/bib2df', 'webchem') # , 'NIVANorge/chemspideR') # no citation available!

## install via CRAN
pacman::p_load(char = pkg_cran)

## install via Github
pacman::p_load_gh(char = pkg_gith)

# pacman::p_update()

# switches ----------------------------------------------------------------
download_db = T # should database query be run
build_db = T # build data base?
download = T # run download scripts (takes days)? 
build = T # run build scripts?
build_standartox = T
build_norman = T
export = F # should data be exported?
debug_mode = F # should only 10 input rows for each quering script be run
sink_console = T # sink console to file

# variables ---------------------------------------------------------------
cachedir = file.path(prj, 'cache')
option = file.path(prj, 'options')
meta = file.path(prj, 'meta')
plotdir = file.path(prj, 'plots')
src = file.path(prj, 'R')
srcrmd = file.path(prj, 'Rmd')
data = file.path(prj, 'data')
data_ecotox = file.path(data, 'ecotox')
data_chebi = file.path(data, 'chebi')
lookupdir = file.path(prj, 'lookup')
cred = file.path(prj, 'cred')
sql = file.path(prj, 'sql')
exportdir = file.path(prj, 'export')
summdir = file.path(prj, 'summary')
## article subfolder
article = file.path(prj, 'article')
datadir_ar = file.path(article, 'data')
## talk subfolder
datadir_tk = file.path(prj, 'talk', 'data')
## shiny application
shinydir = paste0(prj, '-shiny')
shinydata = file.path(shinydir, 'data')
## standartox R-package
standartoxdir = gsub(basename(prj), 'standartox', prj, fixed = TRUE)
## NORMAN
normandir = file.path(prj, 'norman')
cloud = file.path('/home/scharmueller/Nextcloud/norman')

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
nodename = Sys.info()[4]
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
source(file.path(src, 'fun_casconv.R')) # convert between CAS and CASNR
source(file.path(src, 'fun_clean_workspace.R'))
source(file.path(src, 'fun_file_cpy.R'))
source(file.path(src, 'fun_write_db.R'))
source(file.path(src, 'fun_read_db.R'))
source(file.path(src, 'fun_product_na.R'))
source(file.path(src, 'fun_extr_vec.R'))
source(file.path(src, 'fun_cbind_fill.R'))
source(file.path(src, 'fun_log.R'))
source(file.path(src, 'fun_scrape_phantomjs.R'))
source(file.path(src, 'fun_worms_query.R'))
source(file.path(src, 'fun_ln_na.R'))
source(file.path(src, 'fun_paste2.R'))
source(file.path(src, 'fun_norman.R'))
source(file.path(src, 'fun_udunits2_vectorize.R'))
source(file.path(src, 'fun_coalesce.R'))
source(file.path(src, 'fun_clean_names.R'))
source(file.path(src, 'fun_sql_builder.R'))
source(file.path(src, 'fun_mail.R'))
source(file.path(src, 'fun_chck.R'))
source(file.path(src, 'fun_export_db.R'))
source(file.path(src, 'fun_geometric_mean.R'))
source(file.path(src, 'fun_summary_db.R'))
source(file.path(src, 'fun_treemap.R'))
source(file.path(src, 'fun_firstup.R'))

# database ----------------------------------------------------------------
fl = file.path(cred, 'chemspider_apikey.txt')
csapikey = readChar(fl, file.info(fl)$size)
rm(fl)

# library dependencies ----------------------------------------------------
# libsodium - for JS module fs - fun_scrape_phantomjs.R
# phantomjs - headless browser - fun_scrape_phantomjs.R
# libv8-3.14-dev - Google's open source JavaScript engine - fun_scrape_phantomjs.R

## create pgpass file locally in $HOME (for command line data base acces (e.g. pg_dumb))
pgpass = paste(DBhost, DBport, DBetox, DBuser, DBpassword, sep = ':')
write(pgpass, '~/.pgpass')

# plot theme --------------------------------------------------------------
source(file.path(option, 'ggplot_theme_etox_base.R'))
theme_set(theme_minimal_etox_base_sans)

# cite packages -----------------------------------------------------------
pkg = c('pacman', pkg_cran)

for (i in pkg) {
  capture.output(
    utils:::print.bibentry(citation(i), style = "Bibtex"),
    file = file.path(article, 'refs', 'references-etox-base-rpackages.bib'),
    append = TRUE
  )
}




