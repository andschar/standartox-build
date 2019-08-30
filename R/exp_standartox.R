# script to export application data

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# meta information --------------------------------------------------------
q = paste0("SELECT *
            FROM meta.info")

meta = read_tbl(user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
                query = q)
v = meta$etox_version
## output directory
dir = file.path(exportdir, v)
unlink(dir)
mkdirs(dir) # TODO put this into export_tbl()

# export to etox-base repo ------------------------------------------------
## data
# as .fst object
export_tbl(schema = 'standartox', table = 'data2', type = 'fst', debug = FALSE,
           compress = FALSE,
           user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
           dir = dir, file_name = paste0('standartox', v))
# as .fst object (compressed)
export_tbl(schema = 'standartox', table = 'data2', type = 'fst', debug = FALSE,
           compress = TRUE,
           user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
           dir = dir, file_name = paste0('standartox_comp', v))
# as .feather object
export_tbl(schema = 'standartox', table = 'data2', type = 'feather', debug = FALSE,
           user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
           dir = dir, file_name = paste0('standartox', v))
# as .rds object
export_tbl(schema = 'standartox', table = 'data2', type = 'rds', debug = FALSE,
           compress = TRUE,
           user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
           dir = dir, file_name = paste0('standartox', v))
# as .rda object
export_tbl(schema = 'standartox', table = 'data2', type = 'rda', debug = FALSE,
           compress = TRUE,
           user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
           dir = dir, file_name = paste0('standartox', v))
# as .csv object
export_tbl(schema = 'standartox', table = 'data2', type = 'csv', debug = FALSE,
           user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
           dir = dir, file_name = paste0('standartox', v))
## meta data
fwrite(meta, file.path(dir, paste0('standartox', v, '_meta.csv')))

# log ---------------------------------------------------------------------
log_msg('Export: application data exported')

# cleaning ----------------------------------------------------------------
clean_workspace()

