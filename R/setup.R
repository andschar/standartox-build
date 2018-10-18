# shiny setup script 


# project folder ----------------------------------------------------------
nodename = Sys.info()[4]
if (nodename == 'scharmueller') {
  prj = '/home/andreas/Documents/Projects/etox-base-shiny'
} else if (nodename == 'uwigis') {
  prj = '/home/scharmueller/Projects/etox-base-shiny'
} else {
  stop('New system. Define prj and shinydir variables.')
}

# packages ----------------------------------------------------------------
require(data.table)
require(shiny)
require(shinyjs)
require(shinydashboard)
require(knitr)
require(DT)

# variables ---------------------------------------------------------------
#articledir = file.path(prj, 'article')
fundir = file.path(prj, 'R', 'functions')
datadir = file.path(prj, 'data')
cache = file.path(prj, 'cache')

# source ------------------------------------------------------------------
# functions
source(file.path(fundir, 'fun_ec50filter_aggregation.R'))
source(file.path(fundir, 'fun_ec50filter_aggregation_plots.R'))
source(file.path(fundir, 'fun_ec50filter_meta_plots.R'))
