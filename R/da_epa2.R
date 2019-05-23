# script to prepare and clean EPA ECOTOX data

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
epa2 = readRDS(file.path(cachedir, 'epa1.rds'))

## conversions
source(file.path(src, 'da_epa_result_unit.R'))
source(file.path(src, 'da_epa_test_duration.R'))

## additions
# chemical classification
ch_info_fin = readRDS(file.path(cachedir, 'ch_info_fin.rds'))
# taxonomic information
tx_info_fin = readRDS(file.path(cachedir, 'tx_info_fin.rds'))

# preparation -------------------------------------------------------------
## special characters
for (col in names(epa2)) {
  set(epa2, i = which(epa2[[col]] %in% c('NC', 'NR', '+ NR', '--', '')), j = col, value = NA)
}
## type conversion
## concentration
epa2[ grep('ca|x|~', conc1_mean), conc1_mean := NA ]
epa2[ , conc1_mean := gsub(',', '', conc1_mean) ]
# clean concentration column
epa2[ , conc1_mean := trimws(gsub('^\\+|<|>|\\*|=', '', conc1_mean)) ] # remove '*' and '+' (TODO don't know '+')

# type conversion ---------------------------------------------------------
## concentration
epa2[ , conc1_mean := as.numeric(conc1_mean) ]
## duration
epa2[ , obs_duration_mean := as.numeric(obs_duration_mean) ]

# conversions -------------------------------------------------------------
## units
# remove unuseable units
epa2 = merge(epa2, unit_fin, by = 'conc1_unit', all.x = TRUE)
epa2[ unit_noscience %in% 1L, rm := 'unit' ] # remove nonsense units
epa2[ ! unit_convert == 1L, rm := 'unit' ] # keep conversion units only
epa2[ unit_convert == 1L, conc1_mean_conv := conc1_mean %*na% unit_multi ]
epa2[ unit_convert == 1L, conc1_unit_conv := unit_conv_to ]
# cleaning
cols_rm = grep('^unit_', names(epa2), value = TRUE)
epa2[ , (cols_rm) := NULL ]

## durations
epa2 = merge(epa2, look_dur, by.x = 'obs_duration_unit', by.y = 'dur_unit',
             all.x = TRUE)
# exclude
epa2[ dur_exclude == 'yes', rm := 'duration' ]
# convert
epa2[ dur_conv == 'yes', obs_duration_mean_conv := obs_duration_mean %*na% dur_multiplier ]
epa2[ dur_conv == 'yes', obs_duration_unit_conv := dur_conv_to ]
# cleaning
cols_rm = grep('dur_', names(epa2), value = TRUE)
epa2[ , (cols_rm) := NULL ]

# additions ---------------------------------------------------------------
## chmical info
epa2 = merge(epa2, ch_info_fin, by = 'cas', all.x = TRUE)
## taxa info
epa2 = merge(epa2, tx_info_fin, by.x = 'latin_name', by.y = 'taxon', all.x = TRUE)

# switches ----------------------------------------------------------------
## classified to species level?
epa2[ is.na(tax_genus), gen_lvl := 0L ]
epa2[ is.na(tax_species), spc_lvl := 0L ]

# checks ------------------------------------------------------------------
# check for NAs in most important groups
cols = c('tax_ecotox_grp', 'obs_duration_mean_conv', 'endpoint_grp', 'effect')
na_var = sapply(epa2[ , .SD, .SDcols = cols], function(x) length(which(is.na(x))))

if (sum(na_var) != 0) {
  print(na_var)
  warning('NAs in tax_ecotox_grp') # log warning
}

# remove ------------------------------------------------------------------
## count
meta_rm = epa2[ !is.na(rm), .N, rm]
fwrite(meta_rm, file.path(meta, 'meta_rm.csv'))

epa2 = epa2[ is.na(rm) ]

# writing -----------------------------------------------------------------
## postgres
time = Sys.time()
write_tbl(epa2, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'ecotox_export', tbl = 'epa2',
          comment = 'EPA ECOTOX cleaned export')
Sys.time() - time
## data (rds)
time = Sys.time()
saveRDS(epa2, file.path(cachedir, 'epa2.rds'))
Sys.time() - time
## chemicals list
n_cas = epa2[ , .N, .(cas, chemical_name)][order(cas)]
fwrite(n_cas, file.path(cachedir, 'cas_name_table.csv'))

# log ---------------------------------------------------------------------
msg = 'EPA2: preparation script run'
log_msg(msg)

# cleaning ----------------------------------------------------------------
clean_workspace()


