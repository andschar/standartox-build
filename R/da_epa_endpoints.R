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
# remove / and *
epts[ , endpoint := gsub('/|\\*', '', endpoint) ]
# combine endpoints
epts[ grep('^[A-z]{0,2}10$', endpoint), 
      endpoint_grp := 'XX10' ]
epts[ grep('^[A-z]{0,2}50', endpoint),
      endpoint_grp := 'XX50' ]
epts[ grep('(?i)NOEC|NOEL', endpoint),
      endpoint_grp := 'NOEX' ]
epts[ grep('(?i)LOEC|LOEL', endpoint),
      endpoint_grp := 'LOEX' ]
epts[ is.na(endpoint_grp), endpoint_grp := endpoint ]

# reduce ------------------------------------------------------------------
epts_fin = epts[ , .(N = sum(n)), endpoint ][order(-N)]

epts_fin2 = epts[ , .(N = sum(n)), endpoint_grp ][order(-N)]

# writing -----------------------------------------------------------------
fwrite(epts_fin, file.path(cachedir, 'epts_fin.csv'))
fwrite(epts_fin2, file.path(cachedir, 'epts_fin2.csv'))

# help --------------------------------------------------------------------
## from Elonen Guide p. 52
# * denotes endpoints whose provided acronym was modified
# ECxx - Effective Concentration for xx% of tested organisms
# LCxx - Lethal Concnetration to xx% of test animals
# ICxx - Inhibition concentration to xx% of organisms
# LDxx - Lethal dose to xx% of test animals










