# script to prepare EPA ECOTOX data
# raw data appart from some preparation steps (for use with NORMAN)

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))
source(file.path(src, 'da_epa_query.R'))

# data base
DBetox = readRDS(file.path(cachedir, 'data_base_name_version.rds'))

# merge: addition
source(file.path(src, 'da_epa_doses.R'))
source(file.path(src, 'da_epa_endpoints.R'))
source(file.path(src, 'da_epa_exposure_type.R'))
source(file.path(src, 'da_epa_media.R'))
source(file.path(src, 'da_epa_statistics.R'))
source(file.path(src, 'da_epa_taxonomy.R'))

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
  rm(d, con, drv, i) # larger objects
  rm(casnr, todo_cas) # vectors
  
  ## save
  saveRDS(epa1_l, file.path(cachedir, 'source_epa1_list.rds'))
  
} else {
  epa1_l = readRDS(file.path(cachedir, 'source_epa1_list.rds'))
}

epa1 = rbindlist(epa1_l)

# type conversion ---------------------------------------------------------
## concentration
epa1 = epa1[ !conc1_mean %in% c('', '+ NR', 'NR') ] 
epa1 = epa1[ -grep('ca|x|~', conc1_mean) ]
epa1[ , conc1_mean := gsub(',', '.', conc1_mean) ]
epa1[ grep('\\*', conc1_mean) , conc1_mean_calc := 1L ] # '*' - indicates recalculated values (to ug/L)
# qualifier
epa1[ , qualifier := str_extract(conc1_mean, '<|>') ]
epa1[ is.na(qualifier), qualifier := '=' ]
# clean concentration column
epa1[ , conc1_mean := trimws(gsub('^\\+|<|>|\\*|=', '', conc1_mean)) ] # remove '*' and '+' (TODO don't know '+')
epa1[ , conc1_mean := as.numeric(conc1_mean) ]
## duration
epa1[ , obs_duration_mean := as.numeric(obs_duration_mean) ]

# merges: additional ------------------------------------------------------

# merge doses + control mortality -----------------------------------------
epa1 = merge(epa1, dose_dc, by = 'test_id', all.x = TRUE); rm(dose_dc)
epa1[cm, control_neg_mortality := i.control_neg_mortality, on = 'test_id' ]; rm(cm) # 51
epa1[pm, control_pos_mortality := i.control_pos_mortality, on = 'test_id' ]; rm(pm) # 79
epa1[vm, control_vhc_mortality := i.control_vhc_mortality, on = 'test_id' ]; rm(vm) # 81

# merge entpoints ---------------------------------------------------------
epa1 = merge(epa1, epts, by = 'endpoint', all.x = TRUE); rm(epts)
# cleaning
cols_rm = c('endpoint', 'n') 
epa1[ , (cols_rm) := NULL ]; rm(cols_rm)
setnames(epa1, 'endpoint_cl', 'endpoint')

# exposure type -----------------------------------------------------------
epa1 = merge(epa1, exp_typ, by = 'exposure_type'); rm(exp_typ)

# merge media characteristics ---------------------------------------------
epa1 = merge(epa1, med, by = 'result_id'); rm(med)

# merge statistics --------------------------------------------------------
epa1 = merge(epa1, sta, by = 'result_id', all.x = TRUE); rm(sta)

# merge taxonomy ----------------------------------------------------------
epa1 = merge(epa1, tax, by = 'latin_name'); rm(tax)

# preparation -------------------------------------------------------------
# CAS
epa1[ , cas := casconv(casnr) ]
# Clean effect column
epa1[ , effect := gsub('~|/|*', '', effect) ] # remove ~, /, or * from effect column
# measurement (more detailed effect description)
epa1[ , res_measurement := gsub('\\/', '', measurement) ]
# Endpoint
epa1[ , endpoint := gsub('/|\\*|(\\*/)', '', endpoint) ]
# Exposure typpe
epa1[ , exposure_type := gsub('/|\\*|(\\*/)', '', exposure_type) ]
# Media type
epa1[ , media_type := gsub('/|\\*|(\\*/)', '', media_type) ]
# Test location
# FIELD (A-artificial, N-natural, U-undeterminable), LAB, NR
epa1[ , test_location := gsub('/|\\*|(\\*/)', '', test_location) ]
# Chem analysis method
epa1[ , chem_analysis_method := gsub('\\/', '', chem_analysis_method) ]

# set all "" to NA
for (i in names(epa1)) {
  epa1[get(i) == "", (i) := NA]
}

# NORMAN additions --------------------------------------------------------
# Source
epa1[ , biotest_id := paste0('EPA', result_id) ] # 1
epa1[ , data_source := 'EPA ECOTOX' ] # 2
epa1[ , data_protection := 'public available' ] # 5
epa1[ , data_source_link := 'https://cfpub.epa.gov/ecotox/' ] # 6
epa1[ , editor := 'Andreas Scharmüller' ] # 7
epa1[ , date := as.character(Sys.Date()) ] # 8
# Reference
epa1[ , reference_type := paste0('EPA', reference_number) ] # 10
epa1[ , testing_lab := 'n.a.' ]
# Categorisatiion
# Test substance
# TODO NORMAN substance IDs
epa1[ , norman_substance_id := 'TODO' ] # 20
epa1[ , norman_cas := 'TODO' ] # 21
epa1[ , norman_ec := 'n.a.' ] # 22
epa1[ , test_item := 'n.a.' ] # 25
epa1[ , prep_stock := 'n.a.'] # 29
# Biotest
epa1[ , standard_qualifier := 'n.a.' ] # 30
epa1[ , standard_deviation := 'n.a.' ] # 32
epa1[ , test_method_princip :=
        paste0(tes_additional_comments, ' ', res_additional_comments) ] # 33
epa1[ , glp_certificate := ifelse(test_method == 'GLP', 'yes', 'n.a.') ] #34
epa1[ ,  test_duration_tot := 
        paste0(study_duration_mean, ' ', study_duration_unit) ] # 40
epa1[ , recovery := 'n.a.' ] # 41
# Test organism
epa1[ , body_length_control := 'n.a.' ] # 45
epa1[ , body_length_unit := 'n.a.' ] # 46
epa1[ , cell_density_init := 'n.a.' ] # 49
# Dosing system
epa1[ , culture_handling := 'n.a.' ] # 59
epa1[ , culture_acclimation := 'n.a.' ] # 60
epa1[ , conc_measured := 'n.a.' ] # 62
epa1[ , limit_test := 'n.a.' ] # 64
epa1[ , range_finding_study := 'n.a.' ] # 65
epa1[ , analytical_matrix := ifelse(chem_analysis_method %in%
                                      c('--', 'C', 'NC', 'NR', 'X', 'U'),
                                    'no',
                                    'yes') ] # 66
epa1[ , analytical_schedule := 'n.a.' ] # 67
epa1[ , analytical_method := 'n.a.' ] # 68
epa1[ , analytical_recovery := 'n.a.' ] # 69
epa1[ , loq := 'n.a.' ] # 70
# Controls and study design
epa1[ , control_pos_substance := 'n.a.' ] # 78
# TODO
# dd.vc AS "80", --Vehicle control",
# vm.vehicle_mortality AS "81", --Effects in vehicle control",
# TODO END
epa1[ , media_ph_all := paste0(media_ph_mean, '(',
                               media_ph_min, '-',
                               media_ph_max, ')') ] # 84
epa1[ , media_ph_adjustment := 'n.a.' ] # 85
epa1[ , media_temperature_all := paste0(media_temperature_mean, '(',
                                        media_temperature_min, '-',
                                        media_temperature_max, ')') ] # 86
epa1[ , media_hardness_all := paste0(media_hardness_mean, '(',
                                     media_hardness_min, '-',
                                     media_hardness_max, ')') ] # 94
epa1[ , media_chlorine_all := paste0(media_chlorine_mean, '(',
                                     media_chlorine_min, '-',
                                     media_chlorine_max, ')') ] # 96
epa1[ , media_alkalinity_all := paste0(media_alkalinity_mean, '(',
                                       media_alkalinity_min, '-',
                                       media_alkalinity_max, ')') ] # 98
epa1[ , media_salinity_all := paste0(media_salinity_mean, '(',
                                     media_salinity_min, '-',
                                     media_salinity_max, ')') ] # 100
epa1[ , media_org_matter_all := paste0(media_org_matter_mean, '(',
                                       media_org_matter_min, '-',
                                       media_org_matter_max, ')') ] # 102
epa1[ , dissolved_oxygen_all := paste0(dissolved_oxygen_mean, '(',
                                       dissolved_oxygen_min, '-',
                                       dissolved_oxygen_max, ')') ] # 104
epa1[ , substrate := paste0(substrate, ';', substrate_description) ] # 106
epa1[ , vessel_material := 'n.a.' ] # 107
epa1[ , volume_container := 'n.a.' ] # 108
epa1[ , open_closed := 'n.a.' ] # 109
epa1[ , aeration := 'n.a.' ] # 110
epa1[ , test_medium := 'n.a.' ] # 111
epa1[ , culture_test_medium := 'n.a.' ] # 112
epa1[ , feeding_protocols := 'n.a.' ] # 113
epa1[ , food_type := 'n.a.' ] # 114
# Biological effect
epa1[ , conc1_var := paste0(conc1_min, '-', conc1_max) ] # 124
epa1[ , result_comments := paste0(res_additional_comments, ';', test_characteristics) ] # 127
epa1[ , test_plausability := 'n.a.' ] # 128
# TODO # 129
epa1[ , biological_response := ifelse(endpoint %like% '%*', 'no', 'yes') ] # 130
epa1[ , raw_data_availability := 'n.a.' ] # 131
epa1[ , study_available := 'n.a.' ] # 132
epa1[ , comment_general := paste0(tes_additional_comments, ' ', res_additional_comments) ] # 133
epa1[ , rely_score := 5L ] # 134
epa1[ , rely_score_system := 'n.a.' ] # 135
epa1[ , rely_rational := 'n.a.' ] # 136
epa1[ , regulatory_purpose := 'n.a.' ] # 137
epa1[ , cell_density_fin := 'n.a.' ] # 138
epa1[ , purpose_flag := 'n.a.' ] # 139
epa1[ , rely_affiliation := 'n.a' ] # 140
epa1[ , cell_abnormal := 'n.a.' ] # 141
epa1[ , control_negative := 'n.a.' ] # 142
epa1[ , resp_description := tolower(resp_description) ] # 143
epa1[ , organism_lth_fin := 'n.a.' ]
epa1[ , lipid_method := 'n.a.' ] # 145
epa1[ , ecotox_ds_id := 'n.a.' ] # 147
epa1[ , ctrl_description := tolower(ctrl_description) ] # 148

# checks ------------------------------------------------------------------
## (1) NA CAS or CASNR?
cas_chck = 
  epa1[ is.na(casnr) | casnr == '' |
          is.na(cas) | cas == '' ]
if (nrow(cas_chck) != 0) {
  msg = paste0(nrow(cas_chck), ' missing CAS or CASNR.') 
  log_msg(msg)
  stop(msg)
}

## (2) Does a duplicated result_id s show different values (i.e. results)?
dupl_result_id = epa1[ , .N, result_id][order(-N)][N > 1]$result_id
chck_dupl_res_id = epa1[ result_id %in% dupl_result_id,
                         .(mn = mean(conc1_mean, na.rm = TRUE),
                           sd = sd(conc1_mean, na.rm = TRUE)),
                         by = result_id][sd != 0]

if (nrow(chck_dupl_res_id) > 1) {
  msg = 'Duplicated result_id with differing values.'
  log_msg(msg)
  stop(msg)
}

# subseting ---------------------------------------------------------------
## duplicated result_id
# they all have the same result - see chck_dupl_res_id
epa1 = epa1[ !result_id %in% dupl_result_id ]

# writing -----------------------------------------------------------------
#### Etox-Base ----
time = Sys.time()
saveRDS(epa1, file.path(cachedir, 'epa1.rds'))
Sys.time() - time
# taxa
taxa = unique(epa1[ , .SD, .SDcols = c('taxon', 'tax_genus', 'tax_family') ])
saveRDS(taxa, file.path(cachedir, 'epa_taxa.rds'))
# chemical data
chem = unique(epa1[ , .SD, .SDcols = c('casnr', 'cas', 'chemical_name')])
saveRDS(chem, file.path(cachedir, 'epa_chem.rds'))

# NORMAN variables --------------------------------------------------------
look_var = fread(file.path(lookupdir, 'lookup_variables.csv'))
look_var = look_var[ !is.na(key) & key != '' ] #! still an issue in data.taböe_1.11.8
# https://stackoverflow.com/questions/51019041/blank-space-not-recognised-as-na-in-fread
# check 
chck_look_var = nrow( look_var[ ! key %in% names(epa1) ] )
if (chck_look_var != 0) {
  msg = 'Some NORMAN lookup variables can not be found in names(epa1)'
  log_msg(msg)
  stop(msg)
}; rm(chck_no_look)

# integer column names
cols = look_var$key
names(cols) = look_var$id1
cols = cols[ which(cols %in% names(epa1)) ]

# NORMAN table
epa1_norman = epa1[ , .SD, .SDcols = cols ]
setnames(epa1_norman, names(cols))

# epa ecotox_raw data for sharing
time = Sys.time()
fwrite(epa1_norman, file.path(share, 'epa1_raw.csv'))
Sys.time() - time
# epa ecotox raw data example (Triclosan) for sharing
time = Sys.time()
fwrite(epa1_norman[ `21` == '3380345' ],
       file.path(share, 'epa1_raw_triclosan.csv'))
Sys.time() - time
# meta data
epa1_norman_meta = ln_na(epa1_norman)
setnames(epa1_norman_meta, 'variable', 'id')
epa1_norman_meta[ , variable := cols[ match(epa1_norman_meta$id, names(cols)) ] ] # named v update
setcolorder(epa1_norman_meta, c('id', 'variable'))
setorder(epa1_norman_meta, variable)
fwrite(epa1_norman_meta,
       file.path(share, 'epa1_raw_variables.csv'))

# log ---------------------------------------------------------------------
msg = 'EPA1: raw script run'
log_msg(msg); rm(msg)

# cleaning ----------------------------------------------------------------
rm(q, epa1_l, epa1, epa1_norman, epa1_norman_meta, no_look)
rm(cas_chck, chck_dupl_res_id, dupl_result_id)
rm(taxa, chem)
rm(res, i)
rm(time)



