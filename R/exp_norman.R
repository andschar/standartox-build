# script to export NORMAN data

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# save --------------------------------------------------------------------
## raw data
export_tbl(schema = 'norman', table = 'data', type = 'csv',
           user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox)
## cleaned data
export_tbl(schema = 'norman', table = 'data2', type = 'csv',
           user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox)

# log ---------------------------------------------------------------------
log_msg('Export: application data exported')

# cleaning ----------------------------------------------------------------
clean_workspace()
