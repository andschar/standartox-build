# script to change EPA data
# TODO put this at the end of bd_epa_postgres.R

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# query -------------------------------------------------------------------
q1 = "ALTER TABLE ecotox.tests
      DROP COLUMN IF EXISTS cas;
      ALTER TABLE ecotox.tests
      ADD COLUMN cas text;"
q2 = "UPDATE ecotox.tests SET cas = casconv(test_cas, 'cas');"

drv = dbDriver("PostgreSQL")
con = dbConnect(drv, user = DBuser, dbname = DBetox, host = DBhost, port = DBport, password = DBpassword)

dbSendQuery(con, q1)
dbSendQuery(con, q2)

dbDisconnect(con)
dbUnloadDriver(drv)

# log ---------------------------------------------------------------------
log_msg("DATABASE: changes and additions.")

# clean -------------------------------------------------------------------
clean_workspace()
