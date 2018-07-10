# script to query the PubChem data base

# setup -------------------------------------------------------------------
source('R/setup.R')
# switches
online = online
# online = TRUE

# data --------------------------------------------------------------------
psm = readRDS(file.path(cachedir, 'psm.rds'))

# query -------------------------------------------------------------------
if (online) {
  
  cid = get_cid(psm$cas)

  pc_l = list()
  for (i in 1:length(cid)) {
    cas_qu = names(cid[i])
    cid_qu = cid[[i]]
    message('Querying: CAS:', cas_qu, '; CID:', cid_qu, ' (', i, '/', length(cid), ')')
    
    pc_res = pc_prop(cid_qu)
    
    pc_l[[i]] = pc_res
    names(pc_l)[i] = cas_qu
  } 
  
  saveRDS(pc_l, file.path(cachedir, 'pc_l.rds'))
  saveRDS(cid, file.path(cachedir, 'cid.rds'))
  
} else {
  pc_l = readRDS(file.path(cachedir, 'pc_l.rds'))
  cir = readRDS(file.path(cachedir, 'cid.rds'))
}

# convert all entries to data.tables
# 1 col, 1 row DTs are NAs
# 1 col, >1 row DT are multiple results
pc_l = lapply(pc_l, data.table)

pc = rbindlist(pc_l, fill = TRUE, idcol = 'cas')

# cleaning ----------------------------------------------------------------
rm(list = ls()[!ls() %in% c('pc', 'pc_l')])





