# script to prepare EPA ECOTOX data
# preparation for Etox-Base application

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))
# merge: conversion
source(file.path(src, 'da_epa_conversion_unit.R'))
source(file.path(src, 'da_epa_conversion_duration.R'))

# data --------------------------------------------------------------------
epa2 = readRDS(file.path(cachedir, 'epa1.rds'))

# numeric columns ---------------------------------------------------------
# Remove thousand separator
epa2[ , conc1_mean := gsub(',', '', conc1_mean) ]
# Add qualifier column
pat = '\\*|\\+|~|-|x|<|>|=>|ca'
epa2[ , qualifier := str_extract(conc1_mean, pat) ]
epa2[ is.na(qualifier), qualifier := '=' ]
# concentration column to numeric
epa2[ , conc1_mean := as.numeric(gsub(pat, '', conc1_mean)) ]
# duration column to numeric
# TODO 50000 NA
epa2[ obs_duration_mean %in% c('NR', ''),
      obs_duration_mean := NA ]
epa2[ , obs_duration_mean := as.numeric(obs_duration_mean) ]

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

# preparation -------------------------------------------------------------
# 'NC', 'NR', '--' to NA
for (i in names(epa2)) {
  epa2[ get(i) %in% c('NC', 'NR', '+ NR', '--', ''), (i) := NA ]
}
# Clean effect column
epa2[ , effect := gsub('~|/|*', '', effect) ] # remove ~, /, or * from effect column
# Endpoint
epa2[ , endpoint := gsub('/|\\*|(\\*/)', '', endpoint) ]
# Exposure typpe
epa2[ , exposure_type := gsub('/|\\*|(\\*/)', '', exposure_type) ]
# Media type
epa2[ , med_type := gsub('/|\\*|(\\*/)', '', med_type) ]
# set all "" to NA
for (i in names(epa2)) {
  epa2[get(i) == "", (i) := NA]
}

# new variables -----------------------------------------------------------
# habitat
epa2[ med_type == 'FW', hab_isFre := 1L ]
epa2[ med_type == 'SW', hab_isMar := 1L ]
epa2[ habitat == 'Soil', hab_isTer := 1L ]
epa2[ subhabitat %in% c('P', 'R', 'L'), hab_isFre := 1L ]
epa2[ subhabitat %in% c('E'), hab_isBra := 1L ]
epa2[ subhabitat %in% c('D', 'F', 'G'), hab_isTer := 1L ]
epa2[ subhabitat %in% c('M'), hab_isMar := 1L ]

# final columns -----------------------------------------------------------
med_cols = grep('med_', names(epa2), value = TRUE)

cols_fin = c('test_id', 'result_id', 'casnr', 'cas', 'chemical_name', 'chemical_group',
             'conc1_mean', 'conc1_unit', 'conc1_mean_conv', 'conc1_unit_conv', 'qualifier', 'unit_conv',
             'obs_duration_mean', 'obs_duration_unit', 'obs_duration_mean_conv', 'obs_duration_unit_conv',
             'conc1_type', 'endpoint', 'endpoint_grp', 'effect', 'exposure_type',
             med_cols,
             'hab_isFre', 'hab_isBra', 'hab_isMar', 'hab_isTer',
             'taxon', 'tax_genus', 'tax_family', 'tax_order', 'tax_class', 'tax_superclass', 'tax_phylum',
             'tax_subphylum_div', 'tax_phylum_division', 'tax_kingdom',
             'tax_common_name', 'tax_convgroup', 'tax_invertebrate', 'tax_troph_lvl',
             'source', 'reference_number', 'title', 'author', 'publication_year')

epa2 = epa2[ , .SD, .SDcols = cols_fin ]

# final names -------------------------------------------------------------
che_old = c('chemical_name', 'chemical_group')
che_new = c('che_name', 'che_group')
gen_old = c('conc1_mean', 'conc1_unit', 'conc1_mean_conv', 'conc1_unit_conv', 
            'obs_duration_mean', 'obs_duration_unit', 'obs_duration_mean_conv', 'obs_duration_unit_conv')
gen_new = c('value_orig', 'unit_orig', 'value_fin', 'unit_fin',
            'dur_orig', 'dur_unit_orig', 'dur_fin', 'dur_unit_fin')
tes_old = c('effect', 'endpoint', 'endpoint_grp', 'exposure_type', 'conc1_type')
tes_new = c('tes_effect', 'tes_endpoint', 'tes_endpoint_grp', 'tes_exposure_type', 'tes_conc_type')
ref_old = c('reference_number', 'title', 'author', 'publication_year')
ref_new = c('ref_num', 'ref_title', 'ref_author', 'ref_publ_year')

setnames(epa2,
         old = c(che_old, gen_old, tes_old, ref_old),
         new = c(che_new, gen_new, tes_new, ref_new))

# cleaning
rm(che_old, che_new, gen_old, gen_new, tes_old, tes_new, ref_old, ref_new)

# checks ------------------------------------------------------------------
## (1) NA CAS or CASNR?
cas_chck = 
  epa2[ is.na(casnr) | casnr == '' |
          is.na(cas) | cas == '' ]
if (nrow(cas_chck) != 0) {
  msg = paste0(nrow(cas_chck), ' missing CAS or CASNR.') 
  log_msg(msg)
  stop(msg)
}

## (2) Does a duplicated result_id s show different values (i.e. results)?
dupl_result_id = epa2[ , .N, result_id][order(-N)][N > 1]$result_id
chck_dupl_res_id = epa2[ result_id %in% dupl_result_id,
                         .(mn = mean(value_fin, na.rm = TRUE),
                           sd = sd(value_fin, na.rm = TRUE)),
                         by = result_id][sd != 0]

if (nrow(chck_dupl_res_id) > 1) {
  msg = 'Duplicated result_id with differing values.'
  log_msg(msg)
  stop(msg)
}

# summary stats -----------------------------------------------------------
cols_na_stats = c('value_fin', 'unit_fin', 'dur_fin', 'dur_unit_fin', 'tes_effect', 'tes_endpoint')
epa2_na = epa2[ ,
                lapply(.SD, function(x) length(which(is.na(x)))),
                .SDcols = cols_na_stats ]
epa2_na = data.table(t(epa2_na),
                     keep.rownames = TRUE)
epa2_dupl = data.table(rn = 'dupl_result_id',
                       V1 = length(dupl_result_id))
epa2_ept = data.table(rn = 'endpoint_grp',
                      V1 = nrow(epa2[ ! tes_endpoint_grp %in% c('NOEX', 'XX50', 'LOEX', 'XX10') ]))

epa2_rm_l = rbindlist(list(epa2_na, epa2_dupl, epa2_ept))
setnames(epa2_rm_l, c('variable', 'N_NA'))
setorder(epa2_rm_l, -'N_NA')

# subseting ---------------------------------------------------------------
## (1) Remove duplicated result_id ----
epa2 = epa2[ !result_id %in% dupl_result_id ]

## (2) remove endpoints ----
epa2 = epa2[ tes_endpoint_grp %in% c('NOEX', 'XX50', 'LOEX', 'XX10') ]

## (3) remove NA entries ----
epa2 = epa2[ !is.na(dur_fin) &
               !is.na(dur_unit_fin) &
               !is.na(value_fin) &
               !is.na(unit_fin) &
               !is.na(tes_effect) &
               !is.na(tes_endpoint) ]

# saving ------------------------------------------------------------------
saveRDS(epa2, file.path(cachedir, 'epa.rds'))
taxa = unique(epa2[ , .SD, .SDcols = c('taxon', 'tax_genus', 'tax_family') ])
saveRDS(taxa, file.path(cachedir, 'epa_taxa.rds'))
chem = unique(epa2[ , .SD, .SDcols = c('casnr', 'cas', 'che_name')])
saveRDS(chem, file.path(cachedir, 'epa_chem.rds'))

# log ---------------------------------------------------------------------
msg = 'EPA: preparation script run'
log_msg(msg); rm(msg)

# cleaning ----------------------------------------------------------------

rm(list = grep('chck', ls(), value = TRUE))


