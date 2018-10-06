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

grep('chebi', sort(names(pc)), ignore.case = TRUE)



# final dt ----------------------------------------------------------------
# https://pubchemdocs.ncbi.nlm.nih.gov/about
# CID - non-zero integer PubChem ID
# XLogP - Log P calculated Log P
pc2 = pc[ , .SD, .SDcols = c('cas', 'CID', 'InChIKey', 'IUPACName', 'ExactMass')]
pc2 = pc2[!duplicated(cas)] #! easy way out, although pubchem doesn't provide important information
setnames(pc2, tolower(names(pc2)))
setnames(pc2, c('iupacname', 'exactmass'), c('pc_iupacname', 'pc_exactmass'))

# missing entries ---------------------------------------------------------
na_pc2_inchi = pc2[ is.na(inchikey) ]
message('PubChem: For ', nrow(na_pc2_inchi), '/', nrow(pc2),
        ' CAS no InchiKeys were found.')

if (nrow(na_pc2_inchi) > 0) {
  fwrite(na_pc2_inchi, file.path(missingdir, 'na_pc2_inchi.csv'))
  message('Writing missing data to:\n',
          file.path(missingdir, 'na_pc2_inchi.csv'))
}

# cleaning ----------------------------------------------------------------
oldw = getOption("warn")
options(warn = -1) # shuts off warnings

rm(cir, chem)

options(warn = oldw); rm(oldw)




