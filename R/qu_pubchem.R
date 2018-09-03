# script to query the PubChem data base

# setup -------------------------------------------------------------------
source('R/setup.R')

# data --------------------------------------------------------------------
chem = readRDS(file.path(cachedir, 'epa_chem.rds'))

# query -------------------------------------------------------------------
if (online) {
  
  cid = get_cid(chem$cas)

  pc_l = list()
  for (i in 1:length(cid)) {
    qu_cas = names(cid[i])
    qu_cid = cid[[i]]
    message('Querying: CAS:', qu_cas, '; CID:', qu_cid, ' (', i, '/', length(cid), ')')
    
    pc_res = pc_prop(qu_cid)
    
    pc_l[[i]] = pc_res
    names(pc_l)[i] = qu_cas
  } 
  
  saveRDS(pc_l, file.path(cachedir, 'pc_l.rds'))
  saveRDS(cid, file.path(cachedir, 'cid.rds'))
  
} else {
  pc_l = readRDS(file.path(cachedir, 'pc_l.rds'))
  cid = readRDS(file.path(cachedir, 'cid.rds'))
}

# convert all entries to data.tables
# 1 col, 1 row DTs are NAs
# 1 col, >1 row DT are multiple results
pc_l = lapply(pc_l, data.table)

pc = rbindlist(pc_l, fill = TRUE, idcol = 'cas')
pc[ , V1 := NULL ] # not needed

# cleaning ----------------------------------------------------------------
rm(cir, chem)
#rm(list = ls()[!ls() %in% c('pc', 'pc_l')])


# most likely cas ---------------------------------------------------------
# It happens that multiple substances have the same cas. E.g. Propiconazole 

# pc[ , .N, InChIKey][order(-N)]
# pc[ , .N, InChI][order(-N)]
# pc[ , .N, CanonicalSMILES][order(-N)]
# pc[ , .N, ][order(-N)]
# 
# sort(names(pc))










