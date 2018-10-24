# script to create the final result set

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# data --------------------------------------------------------------------
tests = readRDS(file.path(cachedir, 'tests_fl.rds'))

# final columns -----------------------------------------------------------
cols_fin = 'bla'

tests_fin = tests[ , .SD, .SDcols = cols_fin]

# writing -----------------------------------------------------------------
saveRDS(tests_fin, file.path(cachedir, 'tests_fin.rds'))

# cleaning ----------------------------------------------------------------
rm(tests, tests_fin, cols_fin)

