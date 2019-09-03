# script to load data

# data --------------------------------------------------------------------
time = Sys.time()
dat = read_fst(file.path(datadir, epa_versions_newest, paste0('standartox', epa_versions_newest, '.fst')))
setDT(dat)
Sys.time() - time
# list all taxa for auto completion
taxa_all_list = sort(unique(unlist(dat[ , .SD, .SDcols = grep('tax_', names(dat)) ])))
# meta data
stat_l = readRDS(file.path(datadir, epa_versions_newest, paste0('standartox', epa_versions_newest, '_shiny_stats.rds')))

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

