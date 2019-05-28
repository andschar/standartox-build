# script to export application data

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# save --------------------------------------------------------------------
export_tbl(schema = 'application', table = 'data2', type = 'fst', debug = TRUE,
           user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox)

# log ---------------------------------------------------------------------
log_msg('Export: application data exported')

# cleaning ----------------------------------------------------------------
clean_workspace()


