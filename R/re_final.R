# script to create the final result set

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# data --------------------------------------------------------------------
tests_fin = readRDS(file.path(cachedir, 'tests_ch.rds'))

# final columns -----------------------------------------------------------
cols_gen = c('cas', 'casnr', 'inchikey')
cols_chem_class = c('cgr_fungicides', 'cgr_herbicides', 'cgr_insecticides', 'cgr_repellents', 'cgr_rodenticide')

cols = c(cols_gen,
         cols_chem_class)

## final table
tests_fin = tests_fin[ , .SD, .SDcols = cols ]

# final meta columns ------------------------------------------------------
cols_meta = grep('_src', names(tests_fin), value = TRUE)

tests_fin_meta = tests_fin[ , .SD, .SDcols = cols_meta ]

# meta stats table --------------------------------------------------------
meta_m = melt(tests_fin_meta, measure.vars = names(tests_fin_meta))
meta_stats = meta_m[ ,
                     .(sources = paste0(.SD[ , .N, value ][order(-N)]$value,
                                        collapse = '-'),
                       N = paste0(.SD[ , .N, value ][order(-N)]$N,
                                  collapse = '-')),
                     by = variable ]
meta_stats[ , variable := gsub('_src', '', variable) ]

# writing -----------------------------------------------------------------
# table
saveRDS(tests_fin, file.path(cachedir, 'tests_fin.rds'))
# meta table
saveRDS(tests_fin_meta, file.path(cachedir, 'tests_meta_fin.rds'))
# meta stats table
saveRDS(meta_stats, file.path(cachedir, 'tests_meta_stats.rds'))

# cleaning ----------------------------------------------------------------
rm(tests_ch, tests_fin, tests_fin_meta,
   cols, cols_meta)

