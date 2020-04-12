# setup script for standartox-build

# projects ----------------------------------------------------------------
nodename = Sys.info()[4]
if (nodename == 'scharmueller-t460s') {
  prj = '/home/scharmueller/Projects/standartox-build'
} else if (nodename == 'uwigis') {
  prj = '/home/scharmueller/Projects/standartox-build'
} else {
  stop('New system. Define prj variable.')
}

# switches ----------------------------------------------------------------
download_db = TRUE # should database query be run
build_db = TRUE # build data base?
download = FALSE # run download (dwld) scripts (takes days)? 
build = TRUE # run preparation (prep) scripts?
lookup = F # build lookup_tables
chck = F # unit check scripts
build_standartox = F
build_norman = F
debug_mode = FALSE # should only 10 input rows for each quering script be run
sink_console = F # sink console to file
general = F
report = TRUE # should reports be created? dbreport::

# packages ----------------------------------------------------------------
if (!require('pacman')) {
  install.packages('pacman')
}

pkg_cran = c(
  # convenience
  'devtools',
  'countrycode',
  'R.utils',
  'udunits2',
  # string handling
  'stringi',
  'stringr',
  # web API & scraping
  'rvest',
  'httr',
  'rgbif',
  'taxize',
  'rcrossref',
  # i/o
  'readxl',
  'openxlsx',
  'jsonlite',
  'fst',
  # data handling
  'data.table',
  # database
  'RPostgreSQL',
  'DBI',
  # parallel programing
  'foreach',
  'parallel',
  'doParallel',
  # documentation
  'knitr',
  # ploting
  'ggplot2',
  'scales',
  'treemapify',
  'cowplot',
  'RColorBrewer',
  'treemap',
  # APP
  'shiny',
  'shinyjs',
  'shinyWidgets', # pretty stuff
  'shinydashboard',
  'shinydashboardPlus',
  'knitr',
  'DT',
  'plotly',
  'reactlog',
  # API
  'plumber'
)
pkg_gith = c('ropensci/bib2df', # TODO remove?
             'ropensci/webchem',
             'andschar/dbreport',
             'andschar/standartox')

## install via CRAN
pacman::p_load(char = pkg_cran)# , oldPkgs = pkg_cran) # oldPkgs # passed to utils::update.packages()

## install via Github
pacman::p_load_gh(char = pkg_gith)
# TODO uncomment pacman::p_load_current_gh(char = pkg_gith)

# variables ----------------------------------------------------------------
cachedir = file.path(prj, 'cache')
src = file.path(prj, 'R')
data = file.path(prj, 'data')
data_ecotox = file.path(data, 'ecotox')
lookupdir = file.path(prj, 'lookup')
cred = file.path(prj, 'cred')
sql = file.path(prj, 'sql')
## data base
DBetox = try(readRDS(file.path(cachedir, 'data_base_name_version.rds')))
if(inherits(DBetox, 'try-error')) {
  DBetox = 'DBetox not yet defined'
}
vers = gsub('etox', '', DBetox)
## export/summary
exportdir = file.path(prj, 'export', vers)
mkdirs(exportdir)
summdir = file.path(prj, 'summary', vers)
mkdirs(summdir)
## article subfolder
article = file.path(prj, 'article')
datadir_ar = file.path(article, 'data')
## talk subfolder
datadir_tk = file.path(prj, 'talk', 'data')
## shiny application
appdata = file.path(prj, 'app', 'data')
## standartox R-package
## NORMAN
normandir = file.path(prj, 'norman')
cloud = file.path('/home/scharmueller/Nextcloud')

# debug mode --------------------------------------------------------------
if (debug_mode) {
  DBetox = 'testdb'
}

# path to phantomjs
# TODO check if still needed
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
source(file.path(src, 'fun_mail.R'))
source(file.path(src, 'fun_chck.R'))
source(file.path(src, 'fun_export_db.R'))
source(file.path(src, 'fun_geometric_mean.R'))
source(file.path(src, 'fun_summary_db_perc.R'))
source(file.path(src, 'fun_treemap.R'))
source(file.path(src, 'fun_firstup.R'))
source(file.path(src, 'fun_filename.R'))
source(file.path(src, 'fun_sort_vec.R'))
source(file.path(src, 'fun_read_char.R'))
source(file.path(src, 'fun_as_true.R'))
source(file.path(src, 'fun_word_count.R'))
source(file.path(src, 'fun_export_stamp.R'))
source(file.path(src, 'fun_any_true.R'))
# source(file.path(src, 'fun_better_citekey.R'))

# database ----------------------------------------------------------------
csapikey = read_char(file.path(cred, 'chemspider_apikey.txt'))

# library dependencies ----------------------------------------------------
# libsodium - for JS module fs - fun_scrape_phantomjs.R
# phantomjs - headless browser - fun_scrape_phantomjs.R
# libv8-3.14-dev - Google's open source JavaScript engine - fun_scrape_phantomjs.R

## create pgpass file locally in $HOME (for command line data base acces (e.g. pg_dumb))
pgpass = paste(DBhost, DBport, DBetox, DBuser, DBpassword, sep = ':')
write(pgpass, '~/.pgpass')

# plot theme --------------------------------------------------------------
source(file.path(src, 'ggplot_theme_etox_base.R'))
theme_set(theme_minimal_etox_base_sans)

# cite packages -----------------------------------------------------------
# TODO uncomment after article acceptance
# knitr::write_bib(c(pkg_cran,
#                    gsub('(.+)/(.+)', '\\2', pkg_gith)),
#                  file = file.path(article, 'refs', 'references-standartox-rpackages.bib'))


