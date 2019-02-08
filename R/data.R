# script to load data

# setup -------------------------------------------------------------------
src = file.path(getwd(), 'R')
source(file.path(src, 'setup.R'))

# data --------------------------------------------------------------------
# as .rds (~2.5s)
# time = Sys.time()
# dat = readRDS(file.path(datadir, 'tests_fin.rds'))
# Sys.time() - time
# as feather (~0.7s) #! biut also much bigger file - don't commit
time = Sys.time()
#dat = read_feather(file.path(datadir, 'tests_fin.feather'))
dat = readRDS(file.path(datadir, 'tests_fin.rds'))
setDT(dat)
Sys.time() - time

## test statistics + variable names
te_stats_l = readRDS(file.path(datadir, 'te_stats_l.rds'))

## missing variables
var_missing = fread(file.path(datadir, 'all_variables_na.csv'))

## EPA ECOTOX version
epa_time_stamp = readRDS(file.path(datadir, 'data_base_name_version.rds'))
epa_time_stamp = as.Date(gsub('[^0-9]+', '', epa_time_stamp),
                         format = '%Y%m%d')
version_string = sprintf('This tool builds on EPA ECOTOX data (release: %s)',
                         epa_time_stamp)
