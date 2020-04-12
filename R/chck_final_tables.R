# script to check final tables

fl = list.files(exportdir, pattern = 'fst', full.names = TRUE)


lapply(fl, chck_final_cols)


# q = "SELECT table_schema, table_name, column_name
#      FROM information_schema.columns
#      WHERE table_schema = 'standartox'"
# stx_cols = read_query(user = DBuser, host = DBhost, port = DBport,
#                       password = DBpassword, dbname = DBetox, 
#                       query = q)
# 
# 
# con = DBI::dbConnect(RPostgreSQL::PostgreSQL(),
#                      dbname = DBetox,
#                      host = DBhost,
#                      port = DBport,
#                      user = DBuser,
#                      password = DBpassword)
# l = list()
# for (i in 1:nrow(cols_db)) {
#   
#   col = cols_db[i]
#   message('Fetching: ', paste0(col, collapse = '.'))
#   
#   dat = summary_db_perc(con, col$table_schema, col$table_name, col$column_name)
#   
#   l[[i]] = dat
#   names(l)[i] = col$column_name
# }
# DBI::dbDisconnect(con)
# 
# 
# stx_cols
# 
# 
# cols = c('casnr',
#          'cname',
#          'concentration_unit',
#          'concentration_type', 
#          grep('cro_', cols_db$column_name, value = TRUE),
#          grep('ccl_', cols_db$column_name, value = TRUE),
#          grep('tax_', cols_db$column_name, value = TRUE),
#          'trophic_lvl',
#          grep('hab_', cols_db$column_name, value = TRUE),
#          grep('reg_', cols_db$column_name, value = TRUE),
#          'ecotox_grp',
#          'duration',
#          'effect',
#          'endpoint',
#          'exposure')
# cols_db = cols_db[ column_name %in% cols ]
# 
# 




require(testthat)






# testthat::