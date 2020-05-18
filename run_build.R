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

# EPA ECOTOX database -----------------------------------------------------
source(file.path(src, 'run_db_ecotox.R'), max.deparse.length = mdl)

# identifiers -------------------------------------------------------------
source(file.path(src, 'run_identifiers.R'), max.deparse.length = mdl)

# queries + results -------------------------------------------------------
source(file.path(src, 'run_phch_taxa_queries.R'), max.deparse.length = mdl)
 
# data compilation --------------------------------------------------------
if (build) {
  source(file.path(src, 'qu_phch_compile.R'), max.deparse.length = mdl)
  source(file.path(src, 'qu_taxa_compile.R'), max.deparse.length = mdl)
}

# lookup ------------------------------------------------------------------
if (build) {
  source(file.path(src, 'look_schema.R'), max.deparse.length = mdl)
  source(file.path(src, 'look_unit_result.R'), max.deparse.length = mdl)
  source(file.path(src, 'look_unit_duration.R'), max.deparse.length = mdl)
}

# unit conversion ---------------------------------------------------------
if (build) {
  source(file.path(src, 'conv_unit_result_duration.R'), max.deparse.length = mdl)
}
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
  # NB can only be run on top of Standartox
  # LOOKUP
  source(file.path(normandir, 'R/lookup_variables.R'), max.deparse.length = mdl)
  source(file.path(normandir, 'R/lookup.R'), max.deparse.length = mdl)
  
  # CONTINUE HERE!!!!!!!!!!!!!!!!!!!!
  
  source(file.path(normandir, 'R/lookup_ecotox_group.R'), max.deparse.length = mdl) # TODO doesn't work
  
  source(file.path(normandir, 'R/lookup_acute_chronic_standard.R'), max.deparse.length = mdl)
  # TODO source(file.path(normandir, 'R/lookup_id_cas.R'), max.deparse.length = mdl) # TODO wait for Peter's answer!
  # BUILD
  source(file.path(normandir, 'R/bd_norman.R'), max.deparse.length = mdl)
  source(file.path(normandir, 'R/exp_norman.R'), max.deparse.length = mdl)
  source(file.path(normandir, 'R/cpy_norman.R'), max.deparse.length = mdl)
}
# 
# # check scripts -----------------------------------------------------------
# if (chck) {
#   source(file.path(src, 'chck_unit_result_conversion.R'), max.deparse.length = mdl)
#   source(file.path(src, 'chck_unit_duration_conversion.R'), max.deparse.length = mdl)
#   # TODO source(file.path(src, 'chck_habitat.R'), max.deparse.length = mdl)
# }
# 
# # reports -----------------------------------------------------------------
# if (report) {
#   source(file.path(src, 'rep_conv_unit_result_duration.R'), max.deparse.length = mdl)
# }
# # backup ------------------------------------------------------------------
# if (general) {
#   source(file.path(src, 'gn_backup.R'), max.deparse.length = mdl)
# }

# end ---------------------------------------------------------------------
source(file.path(src, 'gn_end.R'), max.deparse.length = mdl)
readRDS(file.path(cachedir, 'start_time.rds'))

# console log 2 -----------------------------------------------------------
if (sink_console) {
  # Restore output to console
  sink()
  sink(type = "message")
}








