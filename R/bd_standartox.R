# script to build application data

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
fl = file.path(sql, 'standartox_data2.sql')
q2 = readChar(fl, file.info(fl)$size)
fl = file.path(sql, 'standartox_data2_fin.sql')
q2_fin = readChar(fl, file.info(fl)$size)
explanation = fread(file.path(lookupdir, 'lookup_explanation.csv'), na.strings = '')

# query -------------------------------------------------------------------
drv = dbDriver("PostgreSQL")
con = dbConnect(drv, user = DBuser, dbname = DBetox, host = DBhost, port = DBport, password = DBpassword)

dbSendQuery(con, "DROP SCHEMA IF EXISTS standartox CASCADE;")
dbSendQuery(con, "CREATE SCHEMA standartox;")

dbSendQuery(con, q2) # converted data
dbSendQuery(con, q2_fin) # combined data
dbWriteTable(con, value = explanation, name = c('standartox', 'data2_explanation'),
             row.names = FALSE,
             overwrite = TRUE)

dbDisconnect(con)
dbUnloadDriver(drv)

# summary -----------------------------------------------------------------
rmarkdown::render(file.path(srcrmd, 'summary_db_cols_standartox.Rmd'),
                  output_dir = summdir,
                  output_file = 'tests',
                  params = list(
                    title = 'standartox.tests',
                    schema = 'standartox',
                    table = 'tests',
                    output_dir = summdir #! strange that output_dir has to be specified 2 times
                  ))
rmarkdown::render(file.path(srcrmd, 'summary_db_cols_standartox.Rmd'),
                  output_dir = summdir,
                  output_file = 'taxa',
                  params = list(
                    title = 'standartox.taxa',
                    schema = 'standartox',
                    table = 'taxa',
                    output_dir = summdir #! strange that output_dir has to be specified 2 times
                  ))
rmarkdown::render(file.path(srcrmd, 'summary_db_cols_standartox.Rmd'),
                  output_dir = summdir,
                  output_file = 'chemicals',
                  params = list(
                    title = 'standartox.chemicals',
                    schema = 'standartox',
                    table = 'chemicals',
                    output_dir = summdir #! strange that output_dir has to be specified 2 times
                  ))
rmarkdown::render(file.path(srcrmd, 'summary_db_cols_standartox.Rmd'),
                  output_dir = summdir,
                  output_file = 'refs',
                  params = list(
                    title = 'standartox.refs',
                    schema = 'standartox',
                    table = 'refs',
                    output_dir = summdir #! strange that output_dir has to be specified 2 times
                  ))
rmarkdown::render(file.path(srcrmd, 'summary_db_cols_standartox.Rmd'),
                  output_dir = summdir,
                  output_file = 'data2',
                  params = list(
                    title = 'standartox.data2',
                    schema = 'standartox',
                    table = 'data2',
                    output_dir = summdir #! strange that output_dir has to be specified 2 times
                  ))

# log ---------------------------------------------------------------------
log_msg('Standartox: data compiled')

# cleaning ----------------------------------------------------------------
clean_workspace()

