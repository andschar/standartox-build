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

# summary -----------------------------------------------------------------
summary_nor1 = summary_db_all(schema = 'norman', table = 'data1')
summary_nor2 = summary_db_all(schema = 'norman', table = 'data2')

fwrite(summary_nor1, file.path(normandir, 'summary_norman1.csv'))
fwrite(summary_nor2, file.path(normandir, 'summary_norman2.csv'))

# log ---------------------------------------------------------------------
log_msg('Export: application data exported')

# cleaning ----------------------------------------------------------------
clean_workspace()
