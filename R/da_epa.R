# script to query the EPA data base for toxicity test results

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))
source(file.path(src, 'da_epa_query.R'))
source(file.path(src, 'da_epa_taxonomy.R'))
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

# clean and add -----------------------------------------------------------
# 'NC', 'NR', '--' to NA
for (i in names(epa1)) {
  epa1[get(i) %in% c('NC', 'NR', '--'), (i) := NA ]
}
# Remove thousand separator
epa1[ , conc1_mean := gsub(',', '', conc1_mean) ]
# Remove approximated entries
epa1 = epa1[ grep('ca', conc1_mean, invert = TRUE) ]
epa1 = epa1[ grep('>|<', conc1_mean, invert = TRUE) ]
# Add qualifier column
pat = '\\*|\\+'
epa1[ , qualifier := str_extract(epa1$conc1_mean, pat) ]
epa1[ , conc1_mean := as.numeric(gsub(pat, '', conc1_mean)) ]
epa1[ is.na(qualifier), qualifier := '=' ]
# duration column to numeric
epa1[ , obs_duration_mean := as.numeric(epa1$obs_duration_mean) ]
# Clean effect column
epa1[ , effect := gsub('~|/|*', '', effect) ] # remove ~, /, or * from effect column
# Endpoint
epa1[ , endpoint := gsub('/|\\*|(\\*/)', '', endpoint) ]
# Exposure typpe
epa1[ , exposure_type := gsub('/|\\*|(\\*/)', '', exposure_type) ]
# Media type
epa1[ , media_type := gsub('/|\\*|(\\*/)', '', media_type) ]
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

# merge taxonomy ----------------------------------------------------------
setkey(epa1, 'latin_name')
epa1 = merge(epa1, tax, by = 'latin_name')

# merge unit conversion ---------------------------------------------------
epa1 = merge(epa1, unit_fin, by.x = 'conc1_unit', by.y = 'uni_key', all.x = TRUE); rm(unit_fin)
epa1[ uni_conv == 'yes', uni_value := conc1_mean %*na% uni_multi ]
epa1[ uni_conv == 'yes', uni_value_unit := uni_type ]

# cleaning
cols_rm = c('uni_multi', 'uni_u1num', 'uni_u2num', 'uni_type')
epa1[ , (cols_rm) := NULL ]; rm(cols_rm)

# merge duration conversion -----------------------------------------------
epa1 = merge(epa1, duration_fin, by.x = 'obs_duration_unit', by.y = 'dur_key',
             all.x = TRUE); rm(duration_fin)
epa1[ dur_conv == 'yes', dur_value := obs_duration_mean %*na% dur_multiplier ]
epa1[ dur_conv == 'yes', dur_value_unit := dur_conv_to ]

# cleaning
cols_rm = c('dur_conv', 'dur_conv_to', 'dur_multiplier')
epa1[ , (cols_rm) := NULL ]; rm(cols_rm)

# new variables -----------------------------------------------------------
# habitat
epa1[ media_type == 'FW', hab_isFre := 1 ]
epa1[ media_type == 'SW', hab_isMar := 1 ]
epa1[ habitat == 'Soil', hab_isTer := 1 ]
epa1[ subhabitat %in% c('P', 'R', 'L'), hab_isFre := 1 ]
epa1[ subhabitat %in% c('E'), hab_isBra := 1 ]
epa1[ subhabitat %in% c('D', 'F', 'G'), hab_isTer := 1 ]
epa1[ subhabitat %in% c('M'), hab_isMar := 1 ]


# subseting ---------------------------------------------------------------
# remove NA entries
epa1 = epa1[ !is.na(dur_value) &
             !is.na(dur_value_unit) &
             !is.na(uni_value) &
             !is.na(uni_value_unit) &
             !is.na(effect) &
             !is.na(endpoint) ]

# final columns -----------------------------------------------------------
cols_fin = c('casnr', 'cas', 'chemical_name', 'chemical_carrier', 'chemical_group',
             'conc1_mean', 'conc1_unit', 'uni_value', 'uni_unit_conv', 'qualifier', 'uni_conv',
             'obs_duration_mean', 'obs_duration_unit', 'dur_value', 'dur_value_unit',
             'conc1_type', 'endpoint', 'effect', 'exposure_type', 'media_type',
             'hab_isFre', 'hab_isBra', 'hab_isMar', 'hab_isTer',
             'taxon', 'tax_genus', 'tax_family', 'tax_order', 'tax_class', 'tax_superclass', 'tax_phylum',
             'tax_subphylum_div', 'tax_phylum_division', 'tax_kingdom',
             'tax_common_name', 'tax_convgroup', 'tax_aqu_inv', 'tax_troph_lvl',
             'source', 'reference_number', 'title', 'author', 'publication_year')

epa1 = epa1[ , .SD, .SDcols = cols_fin ]

# names -------------------------------------------------------------------
setnames(epa1, 
         old = c('conc1_mean', 'conc1_unit', 'conc1_type', 'uni_value', 'uni_unit_conv',
                 'obs_duration_mean', 'obs_duration_unit', 'dur_value', 'dur_value_unit',
                 'reference_number'),
         new = c('value_orig', 'unit_orig', 'conc_type', 'value', 'unit',
                 'duration_orig', 'duration_unit_orig', 'duration', 'duration_unit',
                 'ref_num'))
setnames(epa1, paste0('ep_', names(epa1)))
setnames(epa1,
         old = c('ep_casnr', 'ep_cas', 'ep_taxon'),
         new = c('casnr', 'cas', 'taxon'))

# checks ------------------------------------------------------------------
# cas
cas_chck = 
  epa1[ is.na(casnr) | casnr == '' |
          is.na(cas) | cas == '' ]
if (nrow(cas_chck) != 0) {
  warning(nrow(cas_chck), ' missing CAS or CASNR.')
}

# saving ------------------------------------------------------------------
saveRDS(epa1, file.path(cachedir, 'epa.rds'))
taxa = unique(epa1[ , .SD, .SDcols = c('taxon', 'ep_tax_family') ])
saveRDS(taxa, file.path(cachedir, 'epa_taxa.rds'))
chem = unique(epa1[ , .SD, .SDcols = c('casnr', 'cas', 'ep_chemical_name')])
saveRDS(chem, file.path(cachedir, 'epa_chem.rds'))

# cleaning ----------------------------------------------------------------
rm(cas_chck, taxa, chem, i, cols_fin)


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


