# script to build norman data

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
q1 = read_char(file.path(sql, 'norman_data1.sql'))
q2 = read_char(file.path(sql, 'norman_data2.sql'))
q1_newest = read_char(file.path(sql, 'norman_data1_newest.sql'))
q2_newest = read_char(file.path(sql, 'norman_data2_newest.sql'))
# q2_removed = read_char(file.path(sql, 'norman_data2_removed.sql'))

# query -------------------------------------------------------------------
drv = dbDriver("PostgreSQL")
con = dbConnect(drv, user = DBuser, dbname = DBetox, host = DBhost, port = DBport, password = DBpassword)

dbSendQuery(con, "DROP SCHEMA IF EXISTS norman CASCADE;
                  CREATE SCHEMA norman;")

dbSendQuery(con, q1) # cleaned data
dbSendQuery(con, q2) # converted data
dbSendQuery(con, q1_newest) # cleaned newest data (acc to published date)
dbSendQuery(con, q2_newest) # cleaned newest data (acc to published date)
# dbSendQuery(con, q2_removed) # removed tests

dbDisconnect(con)
dbUnloadDriver(drv)

# summary -----------------------------------------------------------------
# TODO replace with dbreport
# output_dir = file.path(normandir, 'summary')
# rmarkdown::render(file.path(srcrmd, 'summary_db_cols_norman.Rmd'),
#                   output_dir = output_dir,
#                   output_file = 'data1',
#                   params = list(
#                     title = 'data1: NORMAN raw data summary',
#                     schema = 'norman',
#                     table = 'data1',
#                     # cols = c('nor88test', 'nor88')
#                     output_dir = output_dir
#                   ))
# rmarkdown::render(file.path(srcrmd, 'summary_db_cols_norman.Rmd'),
#                   output_dir = output_dir, #! strange that output_dir has to be specified 2 times
#                   output_file = 'data2',
#                   params = list(
#                     title = 'data2: NORMAN cleaned data summary',
#                     schema = 'norman',
#                     table = 'data2',
#                     #cols = c('nor84', 'nor84b'),
#                     output_dir = output_dir
#                   ))

# log ---------------------------------------------------------------------
log_msg('NORMAN: data compiled')

# cleaning ----------------------------------------------------------------
clean_workspace()
