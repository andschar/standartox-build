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

# cleaning
rm(nodename)

# packages ----------------------------------------------------------------
if (!require('pacman')) install.packages('pacman')

pacman::p_load(data.table,
               feather,
               shiny, shinyjs, shinydashboard,
               knitr, DT)

# p_update() #! do this manually, as unexpected consequences might occur

# options -----------------------------------------------------------------
options(stringsAsFactors = FALSE)

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
source(file.path(fundir, 'fun_output_stats.R'))
source(file.path(fundir, 'fun_casconv.R'))

# data --------------------------------------------------------------------
# as .rds (~2.5s)
# time = Sys.time()
# dat = readRDS(file.path(datadir, 'tests_fin.rds'))
# Sys.time() - time
# as feather (~0.7s) #! biut also much bigger file - don't commit
time = Sys.time()
dat = read_feather(file.path(datadir, 'tests_fin.feather'))
setDT(dat)
Sys.time() - time

## test statistics
te_stats_l = readRDS(file.path(datadir, 'te_stats_l.rds'))







