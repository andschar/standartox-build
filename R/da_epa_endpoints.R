# script to retrieve all endpoints from the current EPA ECOTOX data base
# TODO currently only to have an overview

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# data base
DBetox = readRDS(file.path(cachedir, 'data_base_name_version.rds'))

# query -------------------------------------------------------------------
drv = dbDriver("PostgreSQL")
con = dbConnect(drv, user = DBuser, dbname = DBetox, host = DBhost, port = DBport, password = DBpassword)

epts = dbGetQuery(con, "select distinct endpoint, count(endpoint) n
                        from ecotox.results
                        group by endpoint
                        order by n desc")
setDT(epts)

dbDisconnect(con)
dbUnloadDriver(drv)

# preparation -------------------------------------------------------------
epts[ , endpoint := gsub('/|\\*', '', endpoint) ]
epts_fin = epts[ , .(N = sum(n)), endpoint][order(-N)]

# writing -----------------------------------------------------------------
fwrite(epts_fin, file.path(cachedir, 'epts_fin.csv'))


