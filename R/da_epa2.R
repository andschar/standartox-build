# script to prepare EPA ECOTOX data
# cleaned data export for NORMAN

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# data base
DBetox = readRDS(file.path(cachedir, 'data_base_name_version.rds'))

# merge: conversion
source(file.path(src, 'da_epa_conversion_unit.R'))
source(file.path(src, 'da_epa_conversion_duration.R'))

# data --------------------------------------------------------------------
epa2 = readRDS(file.path(cachedir, 'epa1.rds'))

# cleaning ----------------------------------------------------------------
for (col in names(epa2)) {
  set(epa2, i = which(epa2[[col]] %in% c('NC', 'NR', '+ NR', '--', '')), j = col, value = NA)
}

# merges: conversion ------------------------------------------------------

# merge unit conversion ---------------------------------------------------
epa2 = merge(epa2, unit_fin, by.x = 'conc1_unit', by.y = 'unit_key', all.x = TRUE); rm(unit_fin)
epa2[ unit_conv == 'yes', conc1_mean_conv := conc1_mean %*na% unit_multi ]
epa2[ unit_conv == 'yes', conc1_unit_conv := unit_conv_to ]

# cleaning
cols_rm = c('unit_multi', 'unit_u1num', 'unit_u2num', 'unit_type', 'unit_conv_to')
epa2[ , (cols_rm) := NULL ]; rm(cols_rm)

# merge duration conversion -----------------------------------------------
epa2 = merge(epa2, duration_fin, by.x = 'obs_duration_unit', by.y = 'dur_key',
             all.x = TRUE); rm(duration_fin)
epa2[ dur_conv == 'yes', obs_duration_mean_conv := obs_duration_mean %*na% dur_multiplier ]
epa2[ dur_conv == 'yes', obs_duration_unit_conv := dur_conv_to ]

# cleaning
cols_rm = c('dur_conv', 'dur_conv_to', 'dur_multiplier')
epa2[ , (cols_rm) := NULL ]; rm(cols_rm)

# saving ------------------------------------------------------------------
saveRDS(epa2, file.path(cachedir, 'epa2.rds'))
taxa = unique(epa2[ , .SD, .SDcols = c('taxon', 'tax_genus', 'tax_family') ])
saveRDS(taxa, file.path(cachedir, 'epa2_taxa.rds'))
chem = unique(epa2[ , .SD, .SDcols = c('casnr', 'cas', 'chemical_name')])
saveRDS(chem, file.path(cachedir, 'epa2_chem.rds'))

# NORMAN variables --------------------------------------------------------
no_look = fread(file.path(norman, 'norman_lookup.csv'),
                na.strings = 'NA')
# check 
chck_no_look = nrow( no_look[ status == 'ok' & ! key %in% names(epa2) ] )
if (chck_no_look != 0) {
  msg = 'Some NORMAN lookup variables can not be found in names(epa2)'
  log_msg(msg)
  stop(msg)
}; rm(chck_no_look)

# integer column names
cols = no_look$key
names(cols) = no_look$id1

# NORMAN table
epa2_norman = epa2[ , .SD, .SDcols = cols ]
setnames(epa2_norman, names(cols))

# epa ecotox_raw data for sharing
time = Sys.time()
fwrite(epa2_norman, file.path(share, 'epa2_raw.csv'))
Sys.time() - time
# epa ecotox raw data example (Triclosan) for sharing
time = Sys.time()
fwrite(epa2_norman[ `21` == '3380345' ],
       file.path(share, 'epa2_raw_triclosan.csv'))
Sys.time() - time
# meta data
epa2_norman_meta = ln_na(epa2_norman)
setnames(epa2_norman_meta, 'variable', 'id')
epa2_norman_meta[ , variable := cols[ match(epa2_norman_meta$id, names(cols)) ] ] # named v update
setcolorder(epa2_norman_meta, c('id', 'variable'))
fwrite(epa2_norman_meta,
       file.path(share, 'epa2_raw_variables.csv'))

# log ---------------------------------------------------------------------
msg = 'EPA2: preparation script run'
log_msg(msg); rm(msg)

# cleaning ----------------------------------------------------------------

rm(list = grep('chck', ls(), value = TRUE))


