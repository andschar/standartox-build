# script to create the final result set

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# data --------------------------------------------------------------------
tests_ch = readRDS(file.path(cachedir, 'tests_ch.rds'))

# final columns + order ---------------------------------------------------
cols = grep('_src', names(tests_ch), value = TRUE, invert = TRUE)

cols_gen = c('result_id', 'cas', 'casnr', 'inchikey', 'comp_name', 'value_fin', 'unit_fin', 'dur_fin', 'taxon')
cols_test_param = grep('tes_', cols, value = TRUE) # test parameters
cols_chem_class = grep('cgr_', cols, value = TRUE) # chemical classes
cols_taxa = grep('tax_', cols, value = TRUE) # taxonomic classes
cols_habi = grep('hab_', cols, value = TRUE) # habitat
cols_regi = grep('reg_', cols, value = TRUE) # region information
cols_test_media = grep('med_', cols, value = TRUE) # test media columns
cols_chck = grep('chck_', cols, value = TRUE) # check columns
cols_ref = grep('ref_', cols, value = TRUE) # reference columns

cols_fin = c(cols_gen,
             cols_test_param,
             cols_test_media,
             cols_chem_class,
             cols_taxa,
             cols_habi,
             cols_regi,
             cols_chck,
             cols_ref)

## final table
tests_fin = tests_ch[ , .SD, .SDcols = cols_fin ]

# final meta columns ------------------------------------------------------
cols_src = grep('_src', names(tests_ch), value = TRUE)

tests_fin_src = tests_ch[ , .SD, .SDcols = cols_src ]

# writing -----------------------------------------------------------------
# table
saveRDS(tests_fin, file.path(cachedir, 'tests_fin.rds'))
# as .csv
fwrite(tests_fin, file.path(cachedir, 'tests_fin.csv'))
# colums vector
saveRDS(cols_fin, file.path(cachedir, 'tests_fin_cols.rds'))
# meta table
saveRDS(tests_fin_src, file.path(cachedir, 'tests_fin_src.rds'))

# log ---------------------------------------------------------------------
msg = 'Final tables written'
log_msg(msg); rm(msg)

# cleaning ----------------------------------------------------------------
rm(tests_ch, tests_fin, tests_fin_src)
rm(list = grep('^cols', ls(), value = TRUE))

