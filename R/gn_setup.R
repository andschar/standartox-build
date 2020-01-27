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
lookup = TRUE # build lookup_tables
build_standartox = TRUE
build_norman = F
debug_mode = FALSE # should only 10 input rows for each quering script be run
sink_console = TRUE # sink console to file
general = TRUE

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
  'data.tree',
  'data.table',
  'RPostgreSQL',
  'DBI',
  'vegan',
  'plyr',
  'outliers',
  'feather',
  'ggplot2',
  'ggrepel',
  'ggridges',
  'scales',
  'treemapify',
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
  'knitr'
  # TODO check if all packages are still needed!
)
pkg_gith = c('ropensci/bib2df',
             'ropensci/webchem',
             'andschar/standartox',
             'andschar/dbreport') # , 'NIVANorge/chemspideR') # no citation available!

## install via CRAN
pacman::p_load(char = pkg_cran)

## install via Github
pacman::p_load_gh(char = pkg_gith)

# pacman::p_update()

# variables ----------------------------------------------------------------
cachedir = file.path(prj, 'cache')
src = file.path(prj, 'R')
srcrmd = file.path(prj, 'Rmd') # TODO remove once replaced with dbreport::
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
appdata = file.path(gsub('-build', '-app', prj), 'data')
## standartox R-package
## NORMAN
normandir = file.path(prj, 'norman')
cloud = file.path('/home/scharmueller/Nextcloud/norman')

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
source(file.path(src, 'fun_summary_db.R'))
source(file.path(src, 'fun_treemap.R'))
source(file.path(src, 'fun_firstup.R'))
source(file.path(src, 'fun_filename.R'))
source(file.path(src, 'fun_sort_vec.R'))

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
source(file.path(src, 'ggplot_theme_etox_base.R'))
theme_set(theme_minimal_etox_base_sans)

# cite packages -----------------------------------------------------------
# TODO turn on for final paper draft
# pkg = c('pacman', pkg_cran)
# fl_bib = file.path(article, 'refs', 'references-standartox-build.bib')
# fl_tex = file.path(article, 'supplement', 'r-package-list.tex')
# file.remove(fl_bib)
# file.remove(fl_tex)
# for (i in pkg) {
#   capture.output(
#     print(citation(i), style = "Bibtex"),
#     file = fl_bib,
#     append = TRUE
#   )
#   capture.output(
#     print(citation(i), style = 'latex'),
#     cat('\\newline '), # HACK
#     file = fl_tex,
#     append = TRUE
#   )
# }



