# script to build norman data

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
nor_lookup = fread(file.path(normandir, 'lookup', 'lookup_variables.csv'))
fl = file.path(sql, 'norman_data1.sql')
q1 = readChar(fl, file.info(fl)$size)
fl = file.path(sql, 'norman_data2.sql')
q2 = readChar(fl, file.info(fl)$size)
fl = file.path(sql, 'norman_data1_newest.sql')
q1_newest = readChar(fl, file.info(fl)$size)
fl = file.path(sql, 'norman_data2_newest.sql')
q2_newest = readChar(fl, file.info(fl)$size)
fl = file.path(sql, 'norman_data2_removed.sql')
q2_removed = readChar(fl, file.info(fl)$size)

# query -------------------------------------------------------------------
drv = dbDriver("PostgreSQL")
con = dbConnect(drv, user = DBuser, dbname = DBetox, host = DBhost, port = DBport, password = DBpassword)

dbSendQuery(con, "DROP SCHEMA IF EXISTS norman CASCADE;")
dbSendQuery(con, "CREATE SCHEMA norman;")

dbWriteTable(con, nor_lookup, name = c('norman', 'variables'),
             overwrite = TRUE, row.names = FALSE)

dbSendQuery(con, q1) # cleaned data
dbSendQuery(con, q2) # converted data
dbSendQuery(con, q1_newest) # cleaned newest data (acc to published date)
dbSendQuery(con, q2_newest) # cleaned newest data (acc to published date)
dbSendQuery(con, q2_removed) # removed tests

dbDisconnect(con)
dbUnloadDriver(drv)

# summary -----------------------------------------------------------------
output_dir = file.path(normandir, 'summary')
rmarkdown::render(file.path(srcrmd, 'summary_db_cols_norman.Rmd'),
                  output_dir = output_dir,
                  output_file = 'summary_NORMAN_raw',
                  params = list(
                    title = 'NORMAN raw data summary',
                    schema = 'norman',
                    table = 'data1',
                    # cols = c('nor88test', 'nor88')
                    output_dir = output_dir #! strange that output_dir has to be specified 2 times
                  ))
rmarkdown::render(file.path(srcrmd, 'summary_db_cols_norman.Rmd'),
                  output_dir = output_dir, #! strange that output_dir has to be specified 2 times
                  output_file = 'summary_NORMAN_cleaned',
                  params = list(
                    title = 'NORMAN cleaned data summary',
                    schema = 'norman',
                    table = 'data2',
                    #cols = c('nor84', 'nor84b'),
                    output_dir = output_dir #! strange that output_dir has to be specified 2 times
                  ))
rmarkdown::render(file.path(srcrmd, 'summary_db_cols_norman.Rmd'),
                  output_dir = output_dir, #! strange that output_dir has to be specified 2 times
                  output_file = 'summary_NORMAN_removed',
                  params = list(
                    title = 'NORMAN cleaned data summary',
                    schema = 'norman',
                    table = 'data2_removed',
                    output_dir = output_dir #! strange that output_dir has to be specified 2 times
                  ))

# log ---------------------------------------------------------------------
log_msg('NORMAN: data compiled')

# cleaning ----------------------------------------------------------------
clean_workspace()
