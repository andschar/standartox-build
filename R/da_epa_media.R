# script to query taxonomic entities from the EPA data to retain meaningfull ecotoxicological groups

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# data base
DBetox = readRDS(file.path(cachedir, 'data_base_name_version.rds'))

# (1) query ---------------------------------------------------------------
if (online_db) {
  drv = dbDriver("PostgreSQL")
  con = dbConnect(drv, user = DBuser, dbname = DBetox, host = DBhost, port = DBport, password = DBpassword)
  
  med = dbGetQuery(con, "SELECT
                           media_characteristics.result_id,
                           media_characteristics.media_ph_mean,
                           media_characteristics.media_temperature_mean,
                           media_characteristics.media_temperature_unit,
                           media_characteristics.media_alkalinity_mean,
                           media_characteristics.media_alkalinity_unit,
                           media_characteristics.media_hardness_mean,
                           media_characteristics.media_hardness_unit,
                           media_characteristics.dissolved_oxygen_mean AS media_dissolved_oxygen_mean,
                           media_characteristics.dissolved_oxygen_unit AS media_dissolved_oxygen_unit,
                           media_characteristics.media_salinity_mean,
                           media_characteristics.media_salinity_unit,
                           media_characteristics.media_conductivity_mean,
                           media_characteristics.media_conductivity_unit,
                           media_characteristics.media_org_carbon_mean,
                           media_characteristics.media_org_carbon_unit,
                           media_characteristics.media_humic_acid_mean,
                           media_characteristics.media_humic_acid_unit,
                           media_characteristics.media_magnesium_mean,
                           media_characteristics.media_magnesium_unit,
                           media_characteristics.media_calcium_mean,
                           media_characteristics.media_calcium_unit,
                           media_characteristics.media_sodium_mean,
                           media_characteristics.media_sodium_unit,
                           media_characteristics.media_potassium_mean,
                           media_characteristics.media_potassium_unit,
                           media_characteristics.media_sulfate_mean,
                           media_characteristics.media_sulfate_unit,
                           media_characteristics.media_chlorine_mean,
                           media_characteristics.media_chlorine_unit,
                           media_characteristics.media_diss_carbon_mean,
                           media_characteristics.media_diss_carbon_unit,
                           media_characteristics.media_sulfur_mean,
                           media_characteristics.media_sulfur_unit
                         FROM ecotox.media_characteristics")
  setDT(med)
  # names
  med_cols_orig = grep('media', names(med), value = TRUE)
  med_cols = sub('_mean', '', sub('media', 'med', med_cols_orig))
  setnames(med, med_cols_orig, med_cols)
    
  dbDisconnect(con)
  dbUnloadDriver(drv)
  
  saveRDS(med, file.path(cachedir, 'source_epa_media_characteristics.rds'))
  
} else {
  
  med = readRDS(file.path(cachedir, 'source_epa_media_characteristics.rds'))
}

# names vector
cols = sort(names(med))

# clean and add -----------------------------------------------------------
# 'NC', 'NR', '--' to NA
for (i in names(med)) {
  med[get(i) %in% c('NC', 'NR', '--'), (i) := NA ]
}
# qualifier column for all numeric values
cols_val = grep('unit|result_id', cols, value = TRUE, invert = TRUE) 
pat = '\\*|\\+|\\/' #pat = '[^0-9]'
# remove * and + patterns from values
#! data.table is so damn fast
for (col in cols_val) {
  # https://stackoverflow.com/questions/16943939/elegantly-assigning-multiple-columns-in-data-table-with-lapply
  med[ , (paste0(col, '_symb')) := str_extract(med[[col]], pat) ] # own col for special symbols
  set(med, j = col, value = as.numeric(gsub(pat, '', med[[col]]))) # replace pat with '' & numeric
}

# final dt ----------------------------------------------------------------
cols_fin_not = grep('_symb', names(med), value = TRUE)
med = med[ , .SD, .SDcols =! cols_fin_not ]

# cleaning ----------------------------------------------------------------
rm(pat, cols, cols_val, cols_fin_not)






