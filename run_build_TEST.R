#!/usr/bin/Rscript

# this is the main script that has to be sourced and timed on the platform
# time this script tp run every 2 months
# crontab:
# 00 22 * * * /home/scharmueller/Projects/run_build.sh

# setup -------------------------------------------------------------------
source('~/Projects/standartox-build/R/gn_setup.R', max.deparse.length = mdl)

# console log -------------------------------------------------------------
if (sink_console) {
  con = file(file.path(prj, 'console.log'))
  sink(con, append = TRUE)
  sink(con, append = TRUE, type = 'message')
}

# SCRIPT TO TEST ----------------------------------------------------------

# source(file.path(src, 'qu_comptox_webtest_dwld.R'), max.deparse.length = mdl)

# src ='R'
# source(file.path(src, 'id_compile_table.R'), max.deparse.length = mdl)
# source(file.path(src, 'qu_taxa_compile.R'), max.deparse.length = mdl)
# source(file.path(src, 'qu_phch_compile.R'), max.deparse.length = mdl)
# source(file.path(src, 'look_unit_result.R'), max.deparse.length = mdl)
# source(file.path(src, 'look_unit_duration.R'), max.deparse.length = mdl)
# source(file.path(src, 'conv_unit_result_duration.R'), max.deparse.length = mdl) # converts result units
# source(file.path(src, 'bd_standartox.R'), max.deparse.length = mdl)
# source(file.path(src, 'rep_standartox.R'), max.deparse.length = mdl)
# source(file.path(src, 'chck_unit_result_conversion.R'), max.deparse.length = mdl)
# source(file.path(src, 'chck_unit_duration_conversion.R'), max.deparse.length = mdl)
# source(file.path(src, 'rep_conv_unit_result_duration.R'), max.deparse.length = mdl)
# source(file.path(src, 'exp_standartox.R'), max.deparse.length = mdl)
# source(file.path(src, 'exp_standartox_catalog.R'), max.deparse.length = mdl)
# source(file.path(src, 'cpy_standartox.R'), max.deparse.length = mdl)
# source(file.path(src, 'gn_setup.R'))
# con = DBI::dbConnect(RPostgreSQL::PostgreSQL(), #RPostgres::Postgres(),
#                      dbname = DBetox,
#                      host = DBhost,
#                      port = DBport,
#                      user = DBuser,
#                      password = DBpassword)
# tbl = c('tests', 'tests_fin', 'chemicals', 'taxa', 'refs')
# mapply(dbreport::dbreport,
#        tbl = tbl,
#        output_file = tbl,
#        title = paste0('standartox', '.', tbl),
#        MoreArgs = list(con = con,
#                        schema = 'standartox',
#                        output_dir = file.path(summdir, 'standartox'),
#                        output_format = 'html_document',
#                        verbose = TRUE,
#                        exit = FALSE))
# DBI::dbDisconnect(con)
# 
# source(file.path(src, 'id_etox_dwld.R'), max.deparse.length = mdl)
# source(file.path(src, 'id_wiki_dwld.R'), max.deparse.length = mdl)

# source(file.path(src, 'rep_standartox.R'), max.deparse.length = mdl)
# source(file.path(src, 'exp_standartox.R'), max.deparse.length = mdl)
# source(file.path(src, 'exp_standartox_catalog.R'), max.deparse.length = mdl)

# end ---------------------------------------------------------------------
source(file.path(src, 'gn_end.R'), max.deparse.length = mdl)

# console log 2 -----------------------------------------------------------
if (sink_console) {
  # Restore output to console
  sink()
  sink(type = "message")
}
