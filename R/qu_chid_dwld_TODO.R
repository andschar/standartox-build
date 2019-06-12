# script to download data from chemidplus
# TODO not finished

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
drv = dbDriver("PostgreSQL")
con = dbConnect(drv, user = DBuser, dbname = DBetox, host = DBhost, port = DBport, password = DBpassword)

chem = dbGetQuery(con, "SELECT DISTINCT ON (inchikey) *
                       FROM phch.cir")
setDT(chem)

dbDisconnect(con)
dbUnloadDriver(drv)
  
# debuging
if (debug_mode) {
  chem = chem[1:10]
}

# query -------------------------------------------------------------------
q1 = unique(chem$inchikey)

# TODO check error when querying: ITRJWOMZKQRYTA-RFZYENFJSA-N
# chid = ci_query(q1, type = 'inchikey')

# TODO
# get_ri()
# TODO
# get_etoxid()