# shiny setup script

# project folder ----------------------------------------------------------
nodename = Sys.info()[4]
if (nodename == 'scharmueller-t460s') {
  app = '/home/scharmueller/Projects/standartox-build/app'
} else if (nodename == 'uwigis') {
  app = '/home/scharmueller/Projects/standartox-build/app'
} else {
  stop('New system. Define app and shinydir variables.')
}

# packages ----------------------------------------------------------------
if (!require('pacman'))
  install.packages('pacman')

pkg_cran = c(
  'data.table',
  'fst',
  'shiny',
  'shinyjs',
  'shinyWidgets', # pretty stuff
  'shinydashboard',
  'shinydashboardPlus',
  'knitr',
  'DT',
  'plotly',
  'ssdtools',
  'reactlog',
  # API
  'stringi',
  'jsonlite',
  'plumber'
)

pacman::p_load(char = pkg_cran)

# p_update() # TODO do this manually, as unexpected consequences might occur

# options -----------------------------------------------------------------
options(stringsAsFactors = FALSE,
        shiny.reactlog = TRUE,
        shiny.trace = TRUE)

# variables ---------------------------------------------------------------
src = file.path(app, 'R')
datadir = file.path(app, 'data')
logdir = file.path(app, 'log')
# folder for article references
article = file.path(gsub('-app', '-build', app), 'article')

# source ------------------------------------------------------------------
# functions
source(file.path(src, 'stx_filter.R'))
source(file.path(src, 'stx_aggregate.R'))
source(file.path(src, 'fun_plotly.R'))
source(file.path(src, 'fun_outliers.R'))
source(file.path(src, 'fun_casconv.R'))
source(file.path(src, 'fun_in_catalog.R'))
source(file.path(src, 'fun_handle_input_multiple.R'))
# plot theme
source(file.path(src, 'gg_theme.R'))

# versions ----------------------------------------------------------------
epa_versions = list.dirs(datadir, full.names = FALSE)
epa_versions = epa_versions[ epa_versions != '' ]
epa_versions_newest = max(epa_versions)
datadir2 = file.path(datadir, epa_versions_newest)

# cite packages -----------------------------------------------------------
# NOTE only uncomment locally - TAKES EXTRA TIME
# fl_bib = file.path(article, 'refs', 'references-standartox-app.bib')
# file.remove(fl_bib)
# 
# for (i in pkg_cran) {
#   capture.output(
#     print(citation(i), style = "Bibtex"),
#     file = fl_bib,
#     append = TRUE)
# }


