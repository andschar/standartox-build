# script to prepare and clean NORMAN data

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# data --------------------------------------------------------------------
epa2 = readRDS(file.path(cachedir, 'epa2.rds'))

sort(names(epa2))

epa2_test = epa2[1:100]

time = Sys.time()
nor2 = norman(epa2)
Sys.time() - time


ncol(res)
ncol(epa2_test)



epa_test = epa2[ , .SD, .SDcols = c('cas', 'result_id') ]

res = norman(epa_test)
res
