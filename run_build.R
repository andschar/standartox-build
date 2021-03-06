#!/usr/bin/Rscript

# this is the main script that has to be sourced and timed on the platform
# time this script tp run every 2 months
# crontab:
# 00 22 * * * /home/scharmueller/Projects/run_build.sh

# setup -------------------------------------------------------------------
source('~/Projects/standartox-build/R/gn_setup.R', max.deparse.length = mdl)
saveRDS(Sys.time(), file.path(cachedir, 'start_time.rds'))

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
  source(file.path(src, 'bd_epa_postgres.R'), max.deparse.length = mdl)
  # DB roles
  # TODO source(file.path(src, 'bd_postgres_roles.R'), max.deparse.length = mdl) # TODO  rethink structure
  # Permissions
  # TODO source(file.path(src, 'bd_postgres_permissions.R', max_deparse.length = mdl)) # TODO rethink structure
  # functions
  source(file.path(src, 'bd_sql_functions.R'), max.deparse.length = mdl)
  # errata
  source(file.path(src, 'bd_epa_errata.R'), max.deparse.length = mdl)
  # correct bad units
  source(file.path(src, 'bd_epa_errata_unit.R'), max.deparse.length = mdl)
  # phch and taxa data tables
  source(file.path(src, 'bd_phch_taxa_schema_table.R'), max.deparse.length = mdl)
  # meta files
  source(file.path(src, 'bd_epa_meta.R'), max.deparse.length = mdl) # user guide + codeappendix
  # PPDB
  source(file.path(src, 'bd_ppdb_prep.R'), max.deparse.length = mdl)
  # freshwaterecology.info
  source(file.path(src, 'bd_freshwaterecologyinfo.R'), max.deparse.length = mdl)
}

# identifiers -------------------------------------------------------------
if (download) {
  source(file.path(src, 'id_run_dwld.R'), max.deparse.length = mdl)
}

if (build) {
  source(file.path(src, 'id_run_prep.R'), max.deparse.length = mdl)
  source(file.path(src, 'id_compile_table.R'), max.deparse.length = mdl)
}

# queries + results -------------------------------------------------------
## chemical and biota parameters
if (download) {
  source(file.path(src, 'qu_run_dwld.R'), max.deparse.length = mdl)  
}
if (build) {
  source(file.path(src, 'qu_run_prep.R'), max.deparse.length = mdl)
}
if (report) {
  source(file.path(src, 'rep_query_prep.R'), max.deparse.length = mdl)
}

# merge tables ------------------------------------------------------------
if (build) {
  source(file.path(src, 'qu_phch_compile.R'), max.deparse.length = mdl)
  source(file.path(src, 'qu_taxa_compile.R'), max.deparse.length = mdl)
}

# Lookup ------------------------------------------------------------------
if (lookup) {
  source(file.path(src, 'look_schema.R'), max.deparse.length = mdl)
  source(file.path(src, 'look_unit_result.R'), max.deparse.length = mdl)
  source(file.path(src, 'look_unit_duration.R'), max.deparse.length = mdl)
}

# unit conversion ---------------------------------------------------------
source(file.path(src, 'conv_unit_result_duration.R'), max.deparse.length = mdl)

# Standartox --------------------------------------------------------------
if (build_standartox) {
  source(file.path(src, 'bd_standartox.R'), max.deparse.length = mdl)
  if (report) {
    source(file.path(src, 'rep_standartox.R'), max.deparse.length = mdl)
  }
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
if (chck) {
  source(file.path(src, 'chck_unit_result_conversion.R'), max.deparse.length = mdl)
  source(file.path(src, 'chck_unit_duration_conversion.R'), max.deparse.length = mdl)
}

# reports -----------------------------------------------------------------
source(file.path(src, 'rep_conv_unit_result_duration.R'), max.deparse.length = mdl)

# backup ------------------------------------------------------------------
if (general) {
  source(file.path(src, 'gn_backup.R'), max.deparse.length = mdl)
}

# article -----------------------------------------------------------------
# source(file.path(aritcle, 'R/run_article.R'), max.deparse.length = mdl)

# end ---------------------------------------------------------------------
source(file.path(src, 'gn_end.R'), max.deparse.length = mdl)
readRDS(file.path(cachedir, 'start_time.rds'))

# console log 2 -----------------------------------------------------------
if (sink_console) {
  # Restore output to console
  sink()
  sink(type = "message")
}








