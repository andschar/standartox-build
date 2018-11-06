# script to query the EPA data base for toxicity test results

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))
source(file.path(src, 'da_epa_query.R'))
# merge: addition
source(file.path(src, 'da_epa_taxonomy.R'))
source(file.path(src, 'da_epa_media.R'))
source(file.path(src, 'da_epa_endpoints.R'))
source(file.path(src, 'da_epa_doses.R'))
# merge: conversion
source(file.path(src, 'da_epa_conversion_unit.R'))
source(file.path(src, 'da_epa_conversion_duration.R'))

# data base
DBetox = readRDS(file.path(cachedir, 'data_base_name_version.rds'))

# query -------------------------------------------------------------------
if (online_db) {
  drv = dbDriver("PostgreSQL")
  con = dbConnect(drv, user = DBuser, dbname = DBetox, host = DBhost, port = DBport, password = DBpassword)
  
  res = dbGetQuery(con, "SELECT DISTINCT ON (test_cas) test_cas
                         FROM ecotox.tests
                         ORDER BY test_cas ASC")
  todo_cas = sort(res$test_cas) # all the CAS in the EPA ECOTOX database
  # todo_cas = todo_cas[1:10] # debug me!
  
  epa1_l <- list()
  for (i in seq_along(todo_cas)) {
    casnr <- todo_cas[i]
    d <- dbGetQuery(con, sprintf(q, casnr))
    
    message('Returning ', '(', i, '/', length(todo_cas), '): ', casnr, ' (n = ', nrow(d), ')')
    
    epa1_l[[i]] <- d
    names(epa1_l)[i] <- casnr
    
  }
  
  dbDisconnect(con)
  dbUnloadDriver(drv)
  
  ## cleaning
  rm(d, con, drv) # larger objects
  rm(casnr, todo_cas) # vectors
  
  ## save
  saveRDS(epa1_l, file.path(cachedir, 'source_epa1_list.rds'))
  
} else {
  epa1_l = readRDS(file.path(cachedir, 'source_epa1_list.rds'))
}

epa1 = rbindlist(epa1_l)

# type conversion ---------------------------------------------------------
# 'NC', 'NR', '--' to NA
for (i in names(epa1)) {
  epa1[get(i) %in% c('NC', 'NR', '+ NR', '--', ''), (i) := NA ]
}
# Remove thousand separator
epa1[ , conc1_mean := gsub(',', '', conc1_mean) ]
# Add qualifier column
pat = '\\*|\\+|~|-|x|<|>|=>|ca'
epa1[ , qualifier := str_extract(conc1_mean, pat) ]
epa1[ , conc1_mean := as.numeric(gsub(pat, '', conc1_mean)) ]
epa1[ is.na(qualifier), qualifier := '=' ]
# duration column to numeric
epa1[ , obs_duration_mean := as.numeric(obs_duration_mean) ]

# (1) merges: additional --------------------------------------------------
# merge taxonomy ----------------------------------------------------------
epa1 = merge(epa1, tax, by = 'latin_name'); rm(tax)

# merge media characteristics ---------------------------------------------
epa1 = merge(epa1, med, by = 'result_id'); rm(med)

# merge entpoints ---------------------------------------------------------
epa1 = merge(epa1, epts, by = 'endpoint', all.x = TRUE); rm(epts)
# cleaning
cols_rm = c('endpoint', 'n') 
epa1[ , (cols_rm) := NULL ]; rm(cols_rm)
setnames(epa1, 'endpoint_cl', 'endpoint')

# merge doses -------------------------------------------------------------
epa1 = merge(epa1, dose_dc, by = 'test_id', all.x = TRUE)

# raw export --------------------------------------------------------------
# TODO continue here!! manage raw export
# 1) put merges in front of cleaning
# 2) put refinement from this script before cleaning?
# 2) create chemical, organism (habitat, region) as additional postgres tables
time = Sys.time()
fwrite(epa1, file.path(share, 'epa1_raw.csv'))
Sys.time() - time

time = Sys.time()
saveRDS(epa1, file.path(cachedir, 'epa1.rds'))
Sys.time() - time

set.seed(1234)
idx_rnd = sample(1:nrow(epa1), 1000)
# idx_tric = epa1[ cas == 'TODO-CAS' ] # TODO find CAS from Triclosan
fwrite(epa1[ idx_tric ], file.path(share, 'epa1_raw_sample.csv'))
Sys.time() - time

epa1_meta = ln_na(epa1, names(epa1))

# table columns
fwrite(epa1_meta,
       file.path(share, 'epa1_raw_variables.csv'))

# cleaning
rm(idx_tric)

# (2) merges: conversion --------------------------------------------------
# merge unit conversion ---------------------------------------------------
epa1 = merge(epa1, unit_fin, by.x = 'conc1_unit', by.y = 'unit_key', all.x = TRUE); rm(unit_fin)
epa1[ unit_conv == 'yes', conc1_mean_conv := conc1_mean %*na% unit_multi ]
epa1[ unit_conv == 'yes', conc1_unit_conv := unit_conv_to ]

# cleaning
cols_rm = c('unit_multi', 'unit_u1num', 'unit_u2num', 'unit_type', 'unit_conv_to')
epa1[ , (cols_rm) := NULL ]; rm(cols_rm)

# merge duration conversion -----------------------------------------------
epa1 = merge(epa1, duration_fin, by.x = 'obs_duration_unit', by.y = 'dur_key',
             all.x = TRUE); rm(duration_fin)
epa1[ dur_conv == 'yes', obs_duration_mean_conv := obs_duration_mean %*na% dur_multiplier ]
epa1[ dur_conv == 'yes', obs_duration_unit_conv := dur_conv_to ]

# cleaning
cols_rm = c('dur_conv', 'dur_conv_to', 'dur_multiplier')
epa1[ , (cols_rm) := NULL ]; rm(cols_rm)

# clean and add -----------------------------------------------------------
# Clean effect column
epa1[ , effect := gsub('~|/|*', '', effect) ] # remove ~, /, or * from effect column
# Endpoint
epa1[ , endpoint := gsub('/|\\*|(\\*/)', '', endpoint) ]
# Exposure typpe
epa1[ , exposure_type := gsub('/|\\*|(\\*/)', '', exposure_type) ]
# Media type
epa1[ , med_type := gsub('/|\\*|(\\*/)', '', med_type) ]
# CAS
epa1[ , cas := casconv(casnr) ]
# Source column
epa1[ , source := 'epa_ecotox' ]
# set all "" to NA
for (i in names(epa1)) {
  epa1[get(i) == "", (i) := NA]
}

# cleaning
rm(pat)

# new variables -----------------------------------------------------------
# habitat
epa1[ med_type == 'FW', hab_isFre := 1L ]
epa1[ med_type == 'SW', hab_isMar := 1L ]
epa1[ habitat == 'Soil', hab_isTer := 1L ]
epa1[ subhabitat %in% c('P', 'R', 'L'), hab_isFre := 1L ]
epa1[ subhabitat %in% c('E'), hab_isBra := 1L ]
epa1[ subhabitat %in% c('D', 'F', 'G'), hab_isTer := 1L ]
epa1[ subhabitat %in% c('M'), hab_isMar := 1L ]

# final columns -----------------------------------------------------------
med_cols = grep('med_', names(epa1), value = TRUE)

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

epa2 = epa1[ , .SD, .SDcols = cols_fin ]

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
msg = 'EPA: no errors'
log_msg(msg); rm(msg)

# cleaning ----------------------------------------------------------------
rm(epa1_l,
   lookup, med, tax,
   cas_chck, taxa, chem, i, cols_fin,
   dupl_result_id, chck_epa2_id,
   drv, con)
rm(list = grep('chck', ls(), value = TRUE))

# help --------------------------------------------------------------------
# https://cfpub.epa.gov/ecotox/help.cfm?help_id=CONTENTFAQ&help_type=define&help_back=1#asterisk
# ~ (leading tilde) - 
# / (trailing slash) - denotes that a comment is associated with the data
# * means that this value is calculated 'cause it didn't meet epa standards (22 cases). This is not done anymore 
# + probably stands for more than (16 cases)
# MOR - mortality; POP - population; ITX - Intoxication; GRO - Growth; BEH - Behaviour
# NOC - Multiple or undefined; MPH - Morphology; PHY - Physiology; DVP - Development
# REP - Reproduction; BCM - Biochemistry; ENZ - Enzyme; FDB - Feeding behaviour;
# AVO - Avoidance; HIS - Histology; INJ - Injury; PRS - Ecosystem Process; CEL- Cell
# Gen - Genetics; IMM - Immunological; NR - Not reported

# summary -----------------------------------------------------------------
# removed:
# conc1_mean == NA, ca, >, < # ~ 100 entries
# duplicated result_id # 17252

# epa2 = epa2[ !is.na(dur_fin) &
#                !is.na(dur_unit_fin) &
#                !is.na(value_fin) &
#                !is.na(unit_fin) &
#                !is.na(tes_effect) &
#                !is.na(tes_endpoint) ]
# 
# epa2 endpoint