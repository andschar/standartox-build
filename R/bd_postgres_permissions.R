# script to define group role for accessing the DATA BASE
# HELP: https://www.postgresql.org/docs/11/sql-grant.html
# HELP: https://stackoverflow.com/questions/760210/how-do-you-create-a-read-only-user-in-postgresql

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

role = 'ecotox_read' # TODO put user role definition in gn_setup.R (as it is used by multiple scripts)

# query -------------------------------------------------------------------
drv = dbDriver("PostgreSQL")
con = dbConnect(drv, user = DBuser, dbname = DBetox, host = DBhost, port = DBport, password = DBpassword)

dbSendQuery(con, paste0("GRANT CONNECT ON DATABASE ", DBetox, " TO ", role, ";"))
dbSendQuery(con, paste0("ALTER DEFAULT PRIVILEGES IN SCHEMA public
                          GRANT SELECT ON TABLES TO ", role, ";"))
dbSendQuery(con, "GRANT USAGE ON SCHEMA application TO ecotox_read;")

dbDisconnect(con)
dbUnloadDriver(drv)

# log ---------------------------------------------------------------------
log_msg('Postgres: permissions defined')

# cleaning ----------------------------------------------------------------
clean_workspace()


