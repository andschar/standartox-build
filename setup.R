# shiny setup script

# project folder ----------------------------------------------------------
nodename = Sys.info()[4]
if (nodename == 'scharmueller-t460s') {
  prj = '/home/scharmueller/Projects/standartox-app'
} else if (nodename == 'uwigis') {
  prj = '/home/scharmueller/Projects/standartox-app'
} else {
  stop('New system. Define prj and shinydir variables.')
}

# cleaning
rm(nodename)

# packages ----------------------------------------------------------------
if (!require('pacman'))
  install.packages('pacman')

pkg_cran = c(
  'data.table',
  'feather',
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
src = file.path(prj, 'R')
datadir = file.path(prj, 'data')
# folder for article references
article = file.path(gsub('-app', '-build', prj), 'article')

# source ------------------------------------------------------------------
# functions
source(file.path(src, 'stx_filter.R'))
source(file.path(src, 'stx_aggregate.R'))
source(file.path(src, 'fun_plotly.R'))
source(file.path(src, 'fun_outliers.R'))
source(file.path(src, 'fun_casconv.R'))
source(file.path(src, 'fun_in_catalog.R'))
# plot theme
source(file.path(src, 'gg_theme.R'))

# versions ----------------------------------------------------------------
epa_versions = list.dirs(datadir, full.names = FALSE)
epa_versions = epa_versions[ epa_versions != '' ]
epa_versions_newest = max(epa_versions)

# cite packages -----------------------------------------------------------
fl_bib = file.path(article, 'refs', 'references-standartox-app.bib')
file.remove(fl_bib)

for (i in pkg_cran) {
  capture.output(
    print(citation(i), style = "Bibtex"),
    file = fl_bib,
    append = TRUE)
}


