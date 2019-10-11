# script to export application data

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))
v = basename(exportdir)
unlink(exportdir, recursive = TRUE)
mkdirs(exportdir) # TODO put this into export_tbl()

# export ------------------------------------------------------------------
## data
# as .fst object
export_tbl(schema = 'standartox', table = 'data2', type = 'fst', debug = FALSE,
           compress = FALSE,
           user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
           dir = exportdir, file_name = paste0('standartox', v))
# as .fst object (compressed)
export_tbl(schema = 'standartox', table = 'data2', type = 'fst', debug = FALSE,
           compress = TRUE,
           user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
           dir = exportdir, file_name = paste0('standartox_comp', v))
# as .feather object
export_tbl(schema = 'standartox', table = 'data2', type = 'feather', debug = FALSE,
           user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
           dir = exportdir, file_name = paste0('standartox', v))
# as .rds object
export_tbl(schema = 'standartox', table = 'data2', type = 'rds', debug = FALSE,
           compress = TRUE,
           user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
           dir = exportdir, file_name = paste0('standartox', v))
# as .rda object
export_tbl(schema = 'standartox', table = 'data2', type = 'rda', debug = FALSE,
           compress = TRUE,
           user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
           dir = exportdir, file_name = paste0('standartox', v))
# as .csv object
export_tbl(schema = 'standartox', table = 'data2', type = 'csv', debug = FALSE,
           user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
           dir = exportdir, file_name = paste0('standartox', v))
## explanations
export_tbl(schema = 'standartox', table = 'data2_explanation', type = 'csv', debug = FALSE,
           user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
           dir = exportdir, file_name = paste0('standartox_explanation', v))

# log ---------------------------------------------------------------------
log_msg('Export: application data exported')

# cleaning ----------------------------------------------------------------
clean_workspace()

