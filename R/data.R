# script to load data

# setup -------------------------------------------------------------------
source('R/setup.R')
# variables
version = max(list.dirs(datadir, full.names = FALSE))

# data --------------------------------------------------------------------
time = Sys.time()
dat = read_fst(file.path(datadir, version, paste0('standartox', version, '.fst')))
setDT(dat)
Sys.time() - time
# list all taxa for auto completion
taxa_all_list = sort(unique(unlist(dat[ , .SD, .SDcols = grep('tax_', names(dat)) ])))
# meta data
stat_l = readRDS(file.path(datadir, version, paste0('standartox', version, '_shiny_stats.rds')))

# time = Sys.time()
# dat = read_feather(file.path(export, 'standartox.feather'))
# Sys.time() - time
# 
# time = Sys.time()
# dat = readRDS(file.path(export, 'standartox.rds'))
# Sys.time() - time
# 
# time = Sys.time()
# dat = fread(file.path(export, 'standartox.csv'))
# Sys.time() - time
# 

