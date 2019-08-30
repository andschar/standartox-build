# shiny setup script

# project folder ----------------------------------------------------------
nodename = Sys.info()[4]
if (nodename == 'scharmueller-t460s') {
  prj = '/home/scharmueller/Projects/etox-base-shiny'
  prj_data = '/home/scharmueller/Projects/etox-base'
} else if (nodename == 'uwigis') {
  prj = '/home/scharmueller/Projects/etox-base-shiny'
  prj_data = '/home/scharmueller/Projects/etox-base'
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
  'shinysky', # autocomplete text input
  'shinydashboard',
  'shinydashboardPlus',
  'knitr',
  'DT',
  'plotly',
  'ssdtools',
  'reactlog'
)

pacman::p_load(char = pkg_cran)

# p_update() #! do this manually, as unexpected consequences might occur

# options -----------------------------------------------------------------
options(stringsAsFactors = FALSE,
        shiny.reactlog = TRUE,
        shiny.trace = TRUE)

# variables ---------------------------------------------------------------
# /etox-base-shiny
src = file.path(prj, 'R')
fundir = file.path(src,'functions')
datadir = file.path(prj, 'data')
cache = file.path(prj, 'cache')
# /etox-base
article = file.path(prj_data, 'article')

# source ------------------------------------------------------------------
# functions
source(file.path(fundir, 'fun_filter.R'))
source(file.path(fundir, 'fun_aggregation.R'))
# TODO source(file.path(fundir, 'fun_ssd.R'))
source(file.path(fundir, 'fun_plotly.R'))
source(file.path(fundir, 'fun_outliers.R'))
source(file.path(fundir, 'fun_geometric_mean.R'))

# source(file.path(fundir, 'fun_ec50filter_aggregation_plots.R'))
# source(file.path(fundir, 'fun_ec50filter_meta_plots.R'))
# source(file.path(fundir, 'fun_output_stats.R'))
source(file.path(fundir, 'fun_casconv.R'))
# plot themes
source(file.path(src, 'gg_theme.R'))

# versions ----------------------------------------------------------------
epa_versions = list.dirs(datadir, full.names = FALSE)
epa_versions = epa_versions[ epa_versions != '' ]
epa_versions_newest = max(epa_versions)

# cite packages -----------------------------------------------------------
for (i in pkg_cran) {
  capture.output(
    utils:::print.bibentry(citation(i), style = "Bibtex"),
    file = file.path(article, 'refs', 'references-etox-base-rshinypackages.bib'),
    append = TRUE)
}



