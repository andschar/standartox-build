# shiny setup script

# project folder ----------------------------------------------------------
rootdir = '~/Projects/standartox-build'
app = file.path(rootdir, 'app')

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
  'shinylogs',
  'knitr',
  'DT',
  'plotly',
  'reactlog',
  # API
  'stringi',
  'jsonlite',
  'plumber'
)

pacman::p_load(char = pkg_cran)
pacman::p_load_gh('andschar/standartox')
# p_update() # TODO do this manually, as unexpected consequences might occur

# options -----------------------------------------------------------------
options(stringsAsFactors = FALSE,
        shiny.reactlog = TRUE,
        shiny.trace = TRUE)

# variables ---------------------------------------------------------------
src = file.path(app, 'R')
datadir = file.path(app, 'data')
logdir = file.path(app, 'log')

# source ------------------------------------------------------------------
# functions
source(file.path(src, 'stx_filter.R'))
source(file.path(src, 'fun_plotly.R'))
source(file.path(src, 'fun_casconv.R'))
source(file.path(src, 'fun_in_catalog.R'))
source(file.path(src, 'fun_handle_input_multiple.R'))
source(file.path(src, 'fun_firstup.R'))

# versions ----------------------------------------------------------------
epa_versions = list.dirs(datadir, full.names = FALSE)
epa_versions = epa_versions[ epa_versions != '' ]
epa_versions_newest = max(epa_versions)
datadir2 = file.path(datadir, epa_versions_newest)

