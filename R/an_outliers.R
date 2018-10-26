# script to detect outliers

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# data --------------------------------------------------------------------
tests_ou = readRDS(file.path(cachedir, 'tests_fl.rds'))

# calculation -------------------------------------------------------------

## calculate range
tests_ou[ , `:=`
          (rng_id = paste0(casnr, '_',
                           vegan::make.cepnames(taxon), '_',
                           dur_fin),
           rng = paste0(min(value_fin), '-', max(value_fin)),
           rng_dif = abs(max(value_fin) - min(value_fin)),
           rng_fac = round(max(value_fin) / min(value_fin), 1),
           rng_N = .N),
          by = .(casnr, taxon, dur_fin)]

## determine outliers
tests_ou[ rng_fac > 10, `:=`
          (outl = outliers::scores(value_fin, type = 'iqr', lim = 1.5)),
          by = rng_id ]

# final data --------------------------------------------------------------
cols = c('result_id', grep('rng', names(tests_ou), value = TRUE), 'outl')
tests_ou = tests_ou[ , .SD, .SDcols = cols ]
# outl: NA to FALSE: because range is anyway smaller than 10
tests_ou[ is.na(outl), outl := FALSE ]

# cleaning ----------------------------------------------------------------
rm(cols)







