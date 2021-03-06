# script to upload the test data into PostgreSQL tables
# mainly taken from: http://edild.github.io/localecotox/

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))
etoxdir = readRDS(file.path(cachedir, 'etox_data_path.rds'))

# Check if data.base exists -----------------------------------------------
# (Ch1) check existance
drv = dbDriver("PostgreSQL")
con = dbConnect(drv,
                dbname = DBgeneric,
                user = DBuser,
                host = DBhost,
                port = DBport,
                password = DBpassword)

DBetox_chck1 = dbGetQuery(con, paste0("SELECT datname
                                       FROM pg_catalog.pg_database
                                       WHERE lower(datname) = lower('", DBetox, "');"))

dbDisconnect(con)
dbUnloadDriver(drv)

# (Ch2) if database exists, are there all tables?
if (nrow(DBetox_chck1) == 1) {
  
  drv = dbDriver("PostgreSQL")
  con = dbConnect(drv,
                  dbname = DBetox,
                  user = DBuser,
                  host = DBhost,
                  port = DBport,
                  password = DBpassword)
  
  DBetox_chck2 = dbGetQuery(con, "SELECT count(*)
                                  FROM information_schema.tables
                                  WHERE table_schema = 'ecotox';")
  DBetox_chck2 = as.numeric(DBetox_chck2)
  
  dbDisconnect(con)
  dbUnloadDriver(drv)
  
} else {
  
  DBetox_chck2 = 0
}

if (nrow(DBetox_chck1) != 1 | DBetox_chck2 < 48) {

  # CREATE DB ---------------------------------------------------------------
  drv = dbDriver("PostgreSQL")
  con = dbConnect(drv,
                  dbname = DBgeneric,
                  user = DBuser,
                  host = DBhost,
                  port = DBport,
                  password = DBpassword)
  
  dbSendQuery(con, paste0("DROP DATABASE IF EXISTS ", DBetox, ";"))
  dbSendQuery(con, paste0("CREATE DATABASE ", DBetox, ";"))
  
  dbDisconnect(con)
  dbUnloadDriver(drv)
  
  # TABLES ------------------------------------------------------------------
  drv = dbDriver("PostgreSQL")
  con = dbConnect(drv,
                  dbname = DBetox,
                  user = DBuser,
                  host = DBhost,
                  port = DBport,
                  password = DBpassword)
  
  # clean tables --------
  # not done in loop above due to changes
  # list all .txt files
  files = list.files(etoxdir, pattern = "*.txt", full.names = TRUE)
  # exclude the release notes
  files = files[!grepl('release', files)]
  # extract the file/table names
  nam = gsub(".txt", "", basename(files))
  # for every file, read into R amd copy to postgresql
  for (i in seq_along(files)) {
    message("Read File: ", files[i], "\n")
    dt = fread(files[i], sep = '|', quote = '', na.strings = '')
    dbWriteTable(con, nam[i], value = dt, row.names = FALSE)
  }
  # primary keys --------
  dbSendQuery(con, "ALTER TABLE chemical_carriers ADD PRIMARY KEY (carrier_id)")
  dbSendQuery(con, "ALTER TABLE dose_response_details ADD PRIMARY KEY (dose_resp_detail_id)")
  dbSendQuery(con, "ALTER TABLE dose_response_links ADD PRIMARY KEY (dose_resp_link_id)")
  dbSendQuery(con, "ALTER TABLE dose_responses ADD PRIMARY KEY (dose_resp_id)")
  dbSendQuery(con, "ALTER TABLE doses ADD PRIMARY KEY (dose_id)")
  dbSendQuery(con, "ALTER TABLE media_characteristics ADD PRIMARY KEY (result_id)")
  dbSendQuery(con, "ALTER TABLE results ADD PRIMARY KEY (result_id)")
  dbSendQuery(con, "ALTER TABLE tests ADD PRIMARY KEY (test_id)")
  
  # add indexes --------
  dbSendQuery(con, "CREATE INDEX idx_chemical_carriers_test_id ON chemical_carriers(test_id)")
  dbSendQuery(con, "CREATE INDEX idx_chemical_carriers_cas ON chemical_carriers(cas_number)")
  dbSendQuery(con, "CREATE INDEX idx_dose_response_details_dose_resp_id ON dose_response_details(dose_resp_id)")
  dbSendQuery(con, "CREATE INDEX idx_dose_response_details_dose_id ON dose_response_details(dose_id)")
  dbSendQuery(con, "CREATE INDEX idx_dose_response_links_results_id ON dose_response_links(result_id)")
  dbSendQuery(con, "CREATE INDEX idx_dose_response_links_dose_resp ON dose_response_links(dose_resp_id)")
  dbSendQuery(con, "CREATE INDEX idx_dose_responses_test_id ON dose_responses(test_id)")
  dbSendQuery(con, "CREATE INDEX idx_dose_responses_effect_code ON dose_responses(effect_code)")
  dbSendQuery(con, "CREATE INDEX idx_doses_test_id ON doses(test_id)")
  dbSendQuery(con, "CREATE INDEX idx_results_endpoint ON results(endpoint)")
  dbSendQuery(con, "CREATE INDEX idx_results_test_id ON results(test_id)")
  dbSendQuery(con, "CREATE INDEX idx_results_effect ON results(effect)")
  dbSendQuery(con, "CREATE INDEX idx_results_conc1_unit ON results(conc1_unit)")
  dbSendQuery(con, "CREATE INDEX idx_results_obs_duration_mean ON results(obs_duration_mean)")
  dbSendQuery(con, "CREATE INDEX idx_results_obs_duration_unit ON results(obs_duration_unit)")
  dbSendQuery(con, "CREATE INDEX idx_results_measurement ON results(measurement)")
  dbSendQuery(con, "CREATE INDEX idx_results_response_site ON results(response_site)")
  dbSendQuery(con, "CREATE INDEX idx_results_chem_analysis ON results(chem_analysis_method)")
  dbSendQuery(con, "CREATE INDEX idx_results_significance_code ON results(significance_code)")
  dbSendQuery(con, "CREATE INDEX idx_results_trend ON results(trend)")
  dbSendQuery(con, "CREATE INDEX idx_test_cas ON tests(test_cas)")
  dbSendQuery(con, "CREATE INDEX idx_test_species_number ON tests(species_number)")
  dbSendQuery(con, "CREATE INDEX idx_test_media_type ON tests(media_type)")
  dbSendQuery(con, "CREATE INDEX idx_test_location ON tests(test_location)")
  dbSendQuery(con, "CREATE INDEX idx_test_type ON tests(test_type)")
  dbSendQuery(con, "CREATE INDEX idx_test_study_type ON tests(study_type)")
  dbSendQuery(con, "CREATE INDEX idx_test_method ON tests(test_method)")
  dbSendQuery(con, "CREATE INDEX idx_test_lifestage ON tests(organism_lifestage)")
  dbSendQuery(con, "CREATE INDEX idx_test_gender ON tests(organism_gender)")
  dbSendQuery(con, "CREATE INDEX idx_test_source ON tests(organism_source)")
  dbSendQuery(con, "CREATE INDEX idx_test_exposure ON tests(exposure_type)")
  dbSendQuery(con, "CREATE INDEX idx_test_application_freq_unit ON tests(application_freq_unit)")
  dbSendQuery(con, "CREATE INDEX idx_test_application_type ON tests(application_type)")
  
  
  # move to ecotox schema --------
  dbSendQuery(con, "CREATE SCHEMA IF NOT EXISTS ecotox;")
  dbSendQuery(con, paste0("COMMENT ON SCHEMA ecotox IS 'rebuild of EPA ECOTOX data base';"))
  for (i in nam) {
    q = paste0("ALTER TABLE ", i, " SET SCHEMA ecotox;")
    dbSendQuery(con, q)
  }
  
  dbDisconnect(con)
  dbUnloadDriver(drv)
  
  # VALIDATION --------------------------------------------------------------
  drv = dbDriver("PostgreSQL")
  con = dbConnect(drv,
                  dbname = DBetox,
                  user = DBuser,
                  host = DBhost,
                  port = DBport,
                  password = DBpassword)
  
  # Copy validation tables to server
  files_val = list.files(file.path(etoxdir, "validation"), pattern = "*.txt", 
                         full.names = TRUE)
  nam_val = gsub(".txt", "", basename(files_val))
  for (i in seq_along(files_val)) {
    message("Read File: ", files_val[i], "\n")
    dt = fread(files_val[i], sep = '|', quote = '', na.strings = '')
    dbWriteTable(con, nam_val[i], value = dt, row.names = FALSE)
  }
  
  # Add primary keys (some table without PK -> these are just lookup tables)
  dbSendQuery(con, "ALTER TABLE chemicals ADD PRIMARY KEY (cas_number)")
  dbSendQuery(con, "ALTER TABLE \"references\" ADD PRIMARY KEY (reference_number)")
  dbSendQuery(con, "ALTER TABLE species ADD PRIMARY KEY (species_number)")
  # dbSendQuery(con, "ALTER TABLE species_synonyms ADD PRIMARY KEY (species_number, latin_name)")
  # 2018-10-12: threw an error due to duplicate entries.
  dbSendQuery(con, "ALTER TABLE trend_codes ADD PRIMARY KEY (code)")
  dbSendQuery(con, "ALTER TABLE application_type_codes ADD PRIMARY KEY (code)")
  dbSendQuery(con, "ALTER TABLE application_frequency_codes ADD PRIMARY KEY (code)")
  dbSendQuery(con, "ALTER TABLE exposure_type_codes ADD PRIMARY KEY (code)")
  dbSendQuery(con, "ALTER TABLE chemical_analysis_codes ADD PRIMARY KEY (code)")
  dbSendQuery(con, "ALTER TABLE organism_source_codes ADD PRIMARY KEY (code)")
  dbSendQuery(con, "ALTER TABLE gender_codes ADD PRIMARY KEY (code)")
  dbSendQuery(con, "ALTER TABLE lifestage_codes ADD PRIMARY KEY (code)")
  dbSendQuery(con, "ALTER TABLE response_site_codes ADD PRIMARY KEY (code)")
  dbSendQuery(con, "ALTER TABLE measurement_codes ADD PRIMARY KEY (code)")
  dbSendQuery(con, "ALTER TABLE effect_codes ADD PRIMARY KEY (code)")
  dbSendQuery(con, "ALTER TABLE test_method_codes ADD PRIMARY KEY (code)")
  dbSendQuery(con, "ALTER TABLE field_study_type_codes ADD PRIMARY KEY (code)")
  dbSendQuery(con, "ALTER TABLE test_type_codes ADD PRIMARY KEY (code)")
  dbSendQuery(con, "ALTER TABLE test_location_codes ADD PRIMARY KEY (code)")
  dbSendQuery(con, "ALTER TABLE media_type_codes ADD PRIMARY KEY (code)")
  
  # Add indexes
  dbSendQuery(con, "CREATE INDEX idx_species_latin ON species(latin_name)")
  dbSendQuery(con, "CREATE INDEX idx_species_group ON species(ecotox_group)")
  dbSendQuery(con, "CREATE INDEX idx_media_type ON media_type_codes(code)")
  
  # change name and schema of references
  dbSendQuery(con, 'ALTER TABLE public.\"references\" RENAME TO refs')
  dbSendQuery(con, 'ALTER TABLE public.refs SET SCHEMA ecotox')
  
  # move to ecotox schema
  for (i in nam_val[!nam_val %in% 'references']) {
    q <- paste0("ALTER TABLE ", i, " SET SCHEMA ecotox")
    dbSendQuery(con, q)
  }
  
  dbDisconnect(con)
  dbUnloadDriver(drv)
  
  log_msg(paste(DBetox, 'built into PostgresDB', sep = ' '))
  
} else {
  log_msg('ECOTOX: already built into Postgres DB.')
}

# cleaning ----------------------------------------------------------------
clean_workspace()

