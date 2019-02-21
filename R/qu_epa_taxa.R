# script to query the PubChem data base

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))
online_db = T
# query -------------------------------------------------------------------
if (online_db) {
  drv = dbDriver("PostgreSQL")
  con = dbConnect(drv, user = DBuser, dbname = DBetox, host = DBhost, port = DBport, password = DBpassword)
  
  ep_habi = dbGetQuery(
    con, 
    "SELECT species.latin_name, tests.media_type, tests.organism_habitat, tests.subhabitat
     FROM ecotox.species species
     RIGHT JOIN ecotox.tests tests ON tests.species_number = species.species_number;"
  )
  setDT(ep_habi)
  
  dbDisconnect(con)
  dbUnloadDriver(drv)
  
  saveRDS(ep_habi, file.path(cachedir, 'ep_habi_source.rds'))
  
} else {
  
  ep_habi = readRDS(file.path(cachedir, 'ep_habi_source.rds'))
}

# preparation -------------------------------------------------------------
# tests.organism_habitat: 'soil'
# subhabitat: 'P', 'R', 'L', 'E', 'D', 'F', 'G', 'M' -- Palustrine, Riverine, Lacustrine, Estuarine
ep_habi[ media_type == 'FW', ep_isFre := 1L ]
ep_habi[ media_type == 'SW', ep_isMar := 1L ]
ep_habi[ organism_habitat == 'Soil', ep_isTer := 1L ]
ep_habi[ subhabitat %in% c('P', 'R', 'L'), ep_isFre := 1L ]
ep_habi[ subhabitat %in% c('E'), ep_isBra := 1L ]
ep_habi[ subhabitat %in% c('D', 'F', 'G'), ep_isTer := 1L ]
ep_habi[ subhabitat %in% c('M'), ep_isMar := 1L ]

# final table
ep_habi_fin = ep_habi[ , 
                        lapply(.SD, min), 
                        by = latin_name, 
                        .SDcols = c('ep_isFre', 'ep_isMar', 'ep_isTer', 'ep_isBra') ]
setnames(ep_habi_fin, 'latin_name', 'taxon')

# writing -----------------------------------------------------------------
saveRDS(ep_habi_fin, file.path(cachedir, 'ep_habi_fin.rds'))

# log ---------------------------------------------------------------------
msg = 'EPA taxa habitat script run'
log_msg(msg); rm(msg)

# cleaning ----------------------------------------------------------------
clean_workspace()