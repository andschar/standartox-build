# script to retrieve all endpoints from the current EPA ECOTOX data base

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# data base
DBetox = readRDS(file.path(cachedir, 'data_base_name_version.rds'))

# query -------------------------------------------------------------------
if (online_db) {
  drv = dbDriver("PostgreSQL")
  con = dbConnect(drv, user = DBuser, dbname = DBetox, host = DBhost, port = DBport, password = DBpassword)
  
  epts = dbGetQuery(con, "select distinct endpoint, count(endpoint) n
                          from ecotox.results
                          group by endpoint
                          order by n desc")
  setDT(epts)
  
  dbDisconnect(con)
  dbUnloadDriver(drv)
  
  saveRDS(epts, file.path(cachedir, 'epts.rds'))
  
} else {
  
  epts = readRDS(file.path(cachedir, 'epts.rds'))
}

# preparation -------------------------------------------------------------
# remove / and *
epts[ , endpoint_cl := gsub('/|\\*', '', endpoint) ] # clean endpoint
# combine endpoints
epts[ grep('^[A-z]{0,2}0$', endpoint_cl), 
      endpoint_grp := 'XX0' ]
epts[ grep('^[A-z]{0,2}01$', endpoint_cl), 
      endpoint_grp := 'XX01' ]
epts[ grep('^[A-z]{0,2}10$', endpoint_cl), 
      endpoint_grp := 'XX10' ]
epts[ grep('^[A-z]{0,2}15$', endpoint_cl), 
      endpoint_grp := 'XX15' ]
epts[ grep('^[A-z]{0,2}16$', endpoint_cl), 
      endpoint_grp := 'XX16' ]
epts[ grep('^[A-z]{0,2}20', endpoint_cl),
      endpoint_grp := 'XX20' ]
epts[ grep('^[A-z]{0,2}50', endpoint_cl),
      endpoint_grp := 'XX50' ]
epts[ grep('^[A-z]{0,2}95', endpoint_cl),
      endpoint_grp := 'XX95' ]
epts[ grep('^[A-z]{0,2}99', endpoint_cl),
      endpoint_grp := 'XX99' ]
epts[ grep('^[A-z]{0,2}100', endpoint_cl),
      endpoint_grp := 'XX100' ]
epts[ grep('(?i)NOEC|NOEL', endpoint_cl),
      endpoint_grp := 'NOEX' ]
epts[ grep('(?i)LOEC|LOEL', endpoint_cl),
      endpoint_grp := 'LOEX' ]
epts[ grep('(?i)let', endpoint_cl),
      endpoint_grp := 'LETX' ]
epts[ grep('(?i)zero', endpoint_cl),
      endpoint_grp := 'ZERO' ]
epts[ grep('^NR$', endpoint_cl), 
      endpoint_grp := 'NR' ]

# others
# epts[ is.na(endpoint_grp), endpoint_grp := endpoint_cl ]

# summary -----------------------------------------------------------------
epts_fin = epts[ , .(N = sum(n)), endpoint ][order(-N)]
epts_fin2 = epts[ , .(N = sum(n)), endpoint_grp ][order(-N)]

# writing -----------------------------------------------------------------
fwrite(epts_fin, file.path(cachedir, 'epts_fin.csv'))
fwrite(epts_fin2, file.path(cachedir, 'epts_fin2.csv'))

# cleaning ----------------------------------------------------------------
rm(epts_fin, epts_fin2)

# help --------------------------------------------------------------------
## from Elonen Guide p. 52
# * denotes endpoints whose provided acronym was modified
# ECxx - Effective Concentration for xx% of tested organisms
# LCxx - Lethal Concnetration to xx% of test animals
# ICxx - Inhibition concentration to xx% of organisms
# LDxx - Lethal dose to xx% of test animals










