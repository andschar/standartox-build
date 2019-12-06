#!/usr/bin/Rscript

# this is the main script that has to be sourced and timed on the platform
# time this script tp run every 2 months
# crontab:
# 00 22 * * * /home/scharmueller/Projects/run_build.sh

# setup -------------------------------------------------------------------
saveRDS(Sys.time(), 'cache/start_time')
source('~/Projects/standartox-build/R/gn_setup.R', max.deparse.length = mdl)

# console log -------------------------------------------------------------
if (sink_console) {
  con = file(file.path(prj, 'console.log'))
  sink(con, append = TRUE)
  sink(con, append = TRUE, type = 'message')
}

# build EPA ECOTOX data base ----------------------------------------------
## download
if (download_db) {
  ## EPA ECOTOX data base
  # download
  source(file.path(src, 'bd_epa_download.R'), max.deparse.length = mdl)
}

## build
if (build_db) {
  # build
  source(file.path(src, 'bd_epa_postgres.R'), max.deparse.length = mdl) # TODO rethink structure
  # DB roles
  # TODO source(file.path(src, 'bd_postgres_roles.R'), max.deparse.length = mdl) # TODO  rethink structure
  # Permissions
  # TODO source(file.path(src, 'bd_postgres_permissions.R', max_deparse.length = mdl)) # TODO rethink structure
  # functions
  source(file.path(src, 'bd_sql_functions.R'), max.deparse.length = mdl)
  # errata
  source(file.path(src, 'bd_epa_errata.R'), max.deparse.length = mdl)
  # changes
  source(file.path(src, 'bd_epa_changes.R'), max.deparse.length = mdl) # TODO move to bd_epa_download.R
  # meta files
  source(file.path(src, 'bd_epa_meta.R'), max.deparse.length = mdl) # user guide + codeappendix
}

# identifiers -------------------------------------------------------------
## 1st identifiers
if (download) {
  source(file.path(src, 'id_cir_dwld.R'), max.deparse.length = mdl) # CIR
}

if (build) {
  source(file.path(src, 'id_cir_prep.R'), max.deparse.length = mdl)
}

## 2nd identifiers 
if (download) {
  source(file.path(src, 'id_pc_cid_dwld.R'), max.deparse.length = mld) # PubChem
  # TODO source(file.path(src, 'qu_cs_csid_dwld.R'), max.deparse.length = mdl) # Chemspider
  source(file.path(src, 'id_epa_tax_dwld.R'), max.deparse.length = mdl) # EPA: extracts identifiers
}

if (build) {
  source(file.path(src, 'id_pc_cid_prep.R'), max.deparse.length = mld)
  # TODO source(file.path(src, 'id_cs_csid_prep.R'), max.deparse.length = mdl)
  source(file.path(src, 'id_epa_tax_prep.R'), max.deparse.length = mdl)
}

# queries + results -------------------------------------------------------
## chemical and biota parameters
if (download) {
  source(file.path(src, 'qu_run_dwld.R'), max.deparse.length = mdl)  
}

if (build) {
  source(file.path(src, 'qu_run_prep.R'), max.deparse.length = mdl)
}

# merge tables ------------------------------------------------------------
if (build) {
  source(file.path(src, 'qu_run_final.R'), max.deparse.length = mdl)
}

# Lookup ------------------------------------------------------------------
if (lookup) {
  source(file.path(src, 'look_schema.R'), max.deparse.length = mdl)
  source(file.path(src, 'look_concentration_units.R'), max.deparse.length = mdl)
  source(file.path(src, 'look_duration_units.R'), max.deparse.length = mdl)
}

# Standartox --------------------------------------------------------------
if (build_standartox) {
  source(file.path(src, 'bd_standartox.R'), max.deparse.length = mdl)
  source(file.path(src, 'exp_standartox.R'), max.deparse.length = mdl)
  source(file.path(src, 'exp_standartox_catalog.R'), max.deparse.length = mdl)
  # source(file.path(src, 'cpy_standartox.R'), max.deparse.length = mdl)
}

# NORMAN ------------------------------------------------------------------
if (build_norman) {
  # LOOKUP
  source(file.path(src, 'look_norman_variables.R'), max.deparse.length = mdl)
  source(file.path(src, 'look_norman.R'), max.deparse.length = mdl)
  source(file.path(src, 'look_norman_ecotox_group.R'), max.deparse.length = mdl)
  source(file.path(src, 'look_norman_acute_chronic_standard.R'), max.deparse.length = mdl)
  source(file.path(src, 'look_norman_id_cas.R'), max.deparse.length = mdl) # TODO wait for Peter's answer!
  # BUILD
  source(file.path(src, 'bd_norman.R'), max.deparse.length = mdl)
  source(file.path(src, 'exp_norman.R'), max.deparse.length = mdl)
  source(file.path(src, 'cpy_norman.R'), max.deparse.length = mdl)
}

# check scripts -----------------------------------------------------------
source(file.path(src, 'chck_unit_conversions_concentration.R'), max.deparse.length = mdl)
source(file.path(src, 'chck_unit_conversions_duration.R'), max.deparse.length = mdl)

# backup ------------------------------------------------------------------
if (general) {
  source(file.path(src, 'gn_backup.R'), max.deparse.length = mdl)
}

# end ---------------------------------------------------------------------
source(file.path(src, 'gn_end.R'), max.deparse.length = mdl)

# console log 2 -----------------------------------------------------------
if (sink_console) {
  # Restore output to console
  sink()
  sink(type = "message")
}








