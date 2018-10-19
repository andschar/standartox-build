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
               shiny, shinyjs, shinydashboard,
               knitr, DT)

# pacman::p_update()

# options -----------------------------------------------------------------
options(stringsAsFactors=FALSE)

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
dat = readRDS(file.path(datadir, 'tests_fin.rds'))
# tests_stat = fread(file.path(datadir, 'tests_fl_stat.csv'))


# (1) output stats --------------------------------------------------------
out_stats_l = list(
  ## long variables ----
  ep_effect = data.table(
    nam = out_stats_lng(dat, ep_effect)$nam,
    val = out_stats_lng(dat, ep_effect)$ep_effect
  ),
  ep_endpoint = data.table(
    nam = out_stats_lng(dat, ep_endpoint)$nam,
    val = out_stats_lng(dat, ep_endpoint)$ep_endpoint
  ),
  ep_conc_type = data.table(
    nam = out_stats_lng(dat, ep_conc_type)$nam,
    val = out_stats_lng(dat, ep_conc_type)$ep_conc_type,
    n = out_stats_lng(dat, ep_conc_type)$N
  ),
  ## wide variables ----
  continent = out_stats_wid(
    dat,
    c('is_america_north', 'is_america_south', 'is_asia', 'is_oceania', 'is_europe', 'is_africa')
  ),
  habitat = out_stats_wid(
    dat,
    c('is_marin', 'is_brack', 'is_fresh', 'is_terre')
  )
)

# (2) additions -----------------------------------------------------------

out_stats_l$ep_conc_type[ , nam_long := ifelse(val == 'A', 'Active Ingredient',
                                        ifelse(val == 'F', 'Formulation',
                                        ifelse(val == 'T', 'Total (Metals and single elements)',
                                        ifelse(is.na(val), '',
                                        ifelse(val == 'U', 'Unionized',
                                        ifelse(val == 'L', 'Labile', NA)))))) ]

out_stats_l$continent[ , nam_long := ifelse(variable == 'is_america_north', 'North America',
                                     ifelse(variable == 'is_america_south', 'South America',
                                     ifelse(variable == 'is_europe', 'Europe',
                                     ifelse(variable == 'is_asia', 'Asia',
                                     ifelse(variable == 'is_africa', 'Africa',
                                     ifelse(variable == 'is_oceania', 'Oceania', NA)))))) ]
out_stats_l$continent[ , nam_long_stat := paste0(nam_long, ' (', N, ')') ]

out_stats_l$habitat[ , nam_long := ifelse(variable == 'is_marin', 'marin',
                                   ifelse(variable == 'is_brack', 'brackish',
                                   ifelse(variable == 'is_fresh', 'freshwater',
                                   ifelse(variable == 'is_terre', 'terrestrial', NA)))) ]
out_stats_l$habitat[ , nam_long_stat := paste0(nam_long, ' (', N, ')') ]









