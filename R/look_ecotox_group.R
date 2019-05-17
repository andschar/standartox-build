# lookup table for ecotox groups and habitat information
# TODO not finished

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# query -------------------------------------------------------------------
drv = dbDriver("PostgreSQL")
con = dbConnect(drv, user = DBuser, dbname = DBetox, host = DBhost, port = DBport, password = DBpassword)

ecotox_group = data.table(dbGetQuery(
  con,
  "SELECT ecotox_group, COUNT(ecotox_group) n
   FROM ecotox.species
   GROUP BY ecotox_group
   ORDER BY n DESC"
))

dbDisconnect(con)
dbUnloadDriver(drv)

# CONTINUE HERE