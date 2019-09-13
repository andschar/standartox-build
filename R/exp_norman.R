# script to export NORMAN data

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# save --------------------------------------------------------------------
## raw data
# export_tbl(schema = 'norman', table = 'data1', type = c('xlsx', 'rds'),
#            user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
#            dir = file.path(normandir, 'export'))
export_tbl(schema = 'norman', table = 'data1_newest', type = c('xlsx', 'rds'),
           user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
           dir = file.path(normandir, 'export'))
# export_tbl(schema = 'norman', table = 'data2', type = c('xlsx', 'rds'),
#            user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
#            dir = file.path(normandir, 'export'))
export_tbl(schema = 'norman', table = 'data2_newest', type = c('xlsx', 'rds'),
           user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
           dir = file.path(normandir, 'export'))
export_tbl(schema = 'norman', table = 'variables', type = 'csv',
           user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
           dir = file.path(normandir, 'export'))

# copy --------------------------------------------------------------------
file.copy(from = normandir,
          to = cloud,
          recursive = TRUE,
          overwrite = TRUE)

# log ---------------------------------------------------------------------
log_msg('Export: application data exported')

# cleaning ----------------------------------------------------------------
clean_workspace()
