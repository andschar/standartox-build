# script to prepare EPA ECOTOX data
# data export for Etox-Base

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))
source(file.path(src, 'da_epa_comp_classification.R'))

# data --------------------------------------------------------------------
epa3 = readRDS(file.path(cachedir, 'epa2.rds'))

# merge -------------------------------------------------------------------
epa3 = merge(epa3, cla_che, by = 'casnr', all.x = TRUE)

# new variables -----------------------------------------------------------
# habitat
epa3[ media_type == 'FW', ep_isFre := 1L ]
epa3[ media_type == 'SW', ep_isMar := 1L ]
epa3[ organism_habitat == 'Soil', ep_isTer := 1L ]
epa3[ subhabitat %in% c('P', 'R', 'L'), ep_isFre := 1L ]
epa3[ subhabitat %in% c('E'), ep_isBra := 1L ]
epa3[ subhabitat %in% c('D', 'F', 'G'), ep_isTer := 1L ]
epa3[ subhabitat %in% c('M'), ep_isMar := 1L ]

# subsetting --------------------------------------------------------------
## (1) remove endpoints ----
epa3 = epa3[ endpoint_grp %in% c('NOEX', 'XX50', 'LOEX', 'XX10') ]

## (2) remove NA entries ----
epa3 = epa3[ !is.na(obs_duration_mean_conv) &
               !is.na(obs_duration_unit_conv) &
               !is.na(conc1_mean_conv) &
               !is.na(conc1_mean_conv) &
               !is.na(effect) &
               !is.na(endpoint) ]


# final columns -----------------------------------------------------------
# TODO read final columns from lookup file

look_var = fread(file.path(lookupdir, 'lookup_variables.csv'))

cols_fin[ ! cols_fin %in% look_var$app_variable ]

epa1[ , .N, exposure_type]

# final columns -----------------------------------------------------------
# TODO DEPRECATE THIS
cols_fin = c('test_id', 'result_id', 'casnr', 'cas', 'chemical_name', 'ecotox_group',
             'conc1_mean', 'conc1_unit', 'conc1_mean_conv', 'conc1_unit_conv', 'qualifier', 'unit_conv',
             'obs_duration_mean', 'obs_duration_unit', 'obs_duration_mean_conv', 'obs_duration_unit_conv',
             'conc1_type', 'endpoint', 'endpoint_grp', 'effect', 'exposure_type',
             'ep_isFre', 'ep_isBra', 'ep_isMar', 'ep_isTer',
             'ep_metal', 'ep_pesticide',
             'taxon', 'tax_genus', 'tax_family', 'tax_order', 'tax_class', 'tax_superclass', 'tax_phylum',
             'tax_subphylum_div', 'tax_phylum_division', 'tax_kingdom',
             'tax_common_name', 'tax_convgroup', 'tax_invertebrate', 'tax_troph_lvl',
             'source', 'reference_number', 'title', 'author', 'publication_year')

epa3 = epa3[ , .SD, .SDcols = cols_fin ]

# final names -------------------------------------------------------------
che_old = c('chemical_name', 'ecotox_group')
che_new = c('che_name', 'che_group')
gen_old = c('conc1_mean', 'conc1_unit', 'conc1_mean_conv', 'conc1_unit_conv', 
            'obs_duration_mean', 'obs_duration_unit', 'obs_duration_mean_conv', 'obs_duration_unit_conv')
gen_new = c('value_orig', 'unit_orig', 'value_fin', 'unit_fin',
            'dur_orig', 'dur_unit_orig', 'dur_fin', 'dur_unit_fin')
tes_old = c('effect', 'endpoint', 'endpoint_grp', 'exposure_type', 'conc1_type')
tes_new = c('tes_effect', 'tes_endpoint', 'tes_endpoint_grp', 'tes_exposure_type', 'tes_conc_type')
ref_old = c('reference_number', 'title', 'author', 'publication_year')
ref_new = c('ref_num', 'ref_title', 'ref_author', 'ref_publ_year')

setnames(epa3,
         old = c(che_old, gen_old, tes_old, ref_old),
         new = c(che_new, gen_new, tes_new, ref_new))

# writing -----------------------------------------------------------------
saveRDS(epa3, file.path(cachedir, 'epa3.rds'))

# log ---------------------------------------------------------------------
msg = 'EPA3: reduce script run'
log_msg(msg); rm(msg)

# cleaning ----------------------------------------------------------------
rm(che_old, che_new, gen_old, gen_new, tes_old, tes_new, ref_old, ref_new)


