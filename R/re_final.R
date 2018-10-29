# script to create the final result set

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# data --------------------------------------------------------------------
tests_ch = readRDS(file.path(cachedir, 'tests_ch.rds'))

# final columns -----------------------------------------------------------
cols = grep('_src', names(tests_ch), value = TRUE, invert = TRUE)


cols_gen = c('result_id', 'cas', 'casnr', 'inchikey', 'value_fin', 'unit_fin', 'dur_fin', 'taxon')
cols_test_param = grep('tes_', cols, value = TRUE) # test parameters
cols_chem_class = grep('cgr_', cols, value = TRUE) # chemical classes
cols_taxa = grep('tax_', cols, value = TRUE) # taxonomic classes
cols_habi = grep('hab_', cols, value = TRUE) # habitat
cols_regi = grep('reg_', cols, value = TRUE) # region information

cols_fin = c(cols_gen,
             cols_test_param,
             cols_chem_class,
             cols_taxa,
             cols_habi,
             cols_regi)

## final table
tests_fin = tests_ch[ , .SD, .SDcols = cols_fin ]

# final meta columns ------------------------------------------------------
cols_meta = grep('_src', names(tests_ch), value = TRUE)

tests_fin_meta = tests_ch[ , .SD, .SDcols = cols_meta ]

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
saveRDS(tests_fin, file.path(cachedir, 'tests_ch.rds'))
# meta table
saveRDS(tests_fin_meta, file.path(cachedir, 'tests_meta_fin.rds'))
# meta stats table
saveRDS(meta_stats, file.path(cachedir, 'tests_meta_stats.rds'))

# cleaning ----------------------------------------------------------------
rm(tests_ch, tests_fin, tests_fin_meta)
rm(list = grep('^cols', ls(), value = TRUE))

