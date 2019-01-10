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
                           media_characteristics.dissolved_oxygen_min,
                           media_characteristics.dissolved_oxygen_mean,
                           media_characteristics.dissolved_oxygen_max,
                           media_characteristics.dissolved_oxygen_unit,
                           media_characteristics.media_alkalinity_min,
                           media_characteristics.media_alkalinity_mean,
                           media_characteristics.media_alkalinity_max,
                           media_characteristics.media_alkalinity_unit,
                           media_characteristics.media_calcium_min,
                           media_characteristics.media_calcium_mean,
                           media_characteristics.media_calcium_max,
                           media_characteristics.media_calcium_unit,
                           media_characteristics.media_chlorine_min,
                           media_characteristics.media_chlorine_mean,
                           media_characteristics.media_chlorine_max,
                           media_characteristics.media_chlorine_unit,
                           media_characteristics.media_conductivity_min,
                           media_characteristics.media_conductivity_mean,
                           media_characteristics.media_conductivity_max,
                           media_characteristics.media_conductivity_unit,
                           media_characteristics.media_diss_carbon_min,
                           media_characteristics.media_diss_carbon_mean,
                           media_characteristics.media_diss_carbon_max,
                           media_characteristics.media_diss_carbon_unit,
                           media_characteristics.media_hardness_min,
                           media_characteristics.media_hardness_mean,
                           media_characteristics.media_hardness_max,
                           media_characteristics.media_hardness_unit,
                           media_characteristics.media_humic_acid_min,
                           media_characteristics.media_humic_acid_mean,
                           media_characteristics.media_humic_acid_max,
                           media_characteristics.media_humic_acid_unit,
                           media_characteristics.media_magnesium_min,
                           media_characteristics.media_magnesium_mean,
                           media_characteristics.media_magnesium_max,
                           media_characteristics.media_magnesium_unit,
                           media_characteristics.media_org_carbon_min,
                           media_characteristics.media_org_carbon_mean,
                           media_characteristics.media_org_carbon_max,
                           media_characteristics.media_org_carbon_unit,
                           media_characteristics.media_org_matter_min,
                           media_characteristics.media_org_matter_mean,
                           media_characteristics.media_org_matter_max,
                           media_characteristics.media_org_matter_unit,
                           media_characteristics.media_potassium_min,
                           media_characteristics.media_potassium_mean,
                           media_characteristics.media_potassium_max,
                           media_characteristics.media_potassium_unit,
                           media_characteristics.media_ph_min,
                           media_characteristics.media_ph_mean,
                           media_characteristics.media_ph_max,
                           media_characteristics.media_salinity_min,
                           media_characteristics.media_salinity_mean,
                           media_characteristics.media_salinity_max,
                           media_characteristics.media_salinity_unit,
                           media_characteristics.media_sodium_min,
                           media_characteristics.media_sodium_mean,
                           media_characteristics.media_sodium_max,
                           media_characteristics.media_sodium_unit,
                           media_characteristics.media_sulfate_min,
                           media_characteristics.media_sulfate_mean,
                           media_characteristics.media_sulfate_max,
                           media_characteristics.media_sulfate_unit,
                           media_characteristics.media_sulfur_min,
                           media_characteristics.media_sulfur_mean,
                           media_characteristics.media_sulfur_max,
                           media_characteristics.media_sulfur_unit,
                           media_characteristics.media_temperature_min,
                           media_characteristics.media_temperature_mean,
                           media_characteristics.media_temperature_max,
                           media_characteristics.media_temperature_unit
                         FROM ecotox.media_characteristics")
  setDT(med)

  dbDisconnect(con)
  dbUnloadDriver(drv)
  
  saveRDS(med, file.path(cachedir, 'source_epa_media_characteristics.rds'))
  
} else {
  
  med = readRDS(file.path(cachedir, 'source_epa_media_characteristics.rds'))
}



