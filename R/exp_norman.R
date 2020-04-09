# script to export NORMAN data

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# save --------------------------------------------------------------------
## raw data
export_tbl(schema = 'norman', tbl = 'data1', type = 'rds',
           user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
           dir = file.path(normandir, 'export'))
export_tbl(schema = 'norman', tbl = 'data1_newest', type = c('xlsx', 'rds'),
           user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
           dir = file.path(normandir, 'export'))
export_tbl(schema = 'norman', tbl = 'data2', type = 'rds',
           user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
           dir = file.path(normandir, 'export'))
export_tbl(schema = 'norman', tbl = 'data2_newest', type = c('xlsx', 'rds'),
           user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
           dir = file.path(normandir, 'export'))
export_tbl(schema = 'norman', tbl = 'variables', type = 'csv',
           user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
           dir = file.path(normandir, 'export'))

# log ---------------------------------------------------------------------
log_msg('EXPORT: NORMAN: data exported.')

# cleaning ----------------------------------------------------------------
clean_workspace()
