# script that sources analyses scripts (an_*.R)

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# data --------------------------------------------------------------------
tests_an = readRDS(file.path(cachedir, 'tests_fl.rds'))

# source scripts ----------------------------------------------------------

# outliers
source(file.path(src, 'an_outliers.R'))

# acut - chronic classification
# TODO source(file.path(src, 'an_acute_chronic.R'))

# merge -------------------------------------------------------------------

# outliers
tests_an[tests_ou, outl := i.outl, on = 'result_id' ]

# acute & chronic tests
# TODO 

# writing -----------------------------------------------------------------
saveRDS(tests_an, file.path(cachedir, 'tests_an.rds'))

# cleaning ----------------------------------------------------------------
rm(tests_an,
   tests_ou)

