# script to query the PubChem data base

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# data --------------------------------------------------------------------
chem = readRDS(file.path(cachedir, 'epa_chem.rds'))

# query -------------------------------------------------------------------
if (online) {
  
  todo_pc = chem$cas
  todo_pc = todo_pc[1:4] # debuging
  
  cid_l = list()
  for (i in 1:length(todo_pc)) {
    qu_cas = todo_pc[i]
    message('Pubchem: CAS:', qu_cas, ' (', i, '/', length(todo_pc), ') -> to retrieve CID.')
    
    qu_cid = get_cid(qu_cas, verbose = FALSE)
    
    
    cid_l[[i]] = qu_cid
    names(cid_l)[i] = qu_cas
  }
  
  pc_l = list()
  for (i in 1:length(cid_l)) {
    qu_cas = names(cid_l[i])
    qu_cid = cid_l[[i]]
    message('Pubchem: CAS:', qu_cas, '; CID:', qu_cid, ' (', i, '/', length(cid_l),
            ') -> to retrieve data.')
    
    pc_res = pc_prop(qu_cid, verbose = FALSE)
    
    pc_l[[i]] = pc_res
    names(pc_l)[i] = qu_cas
  } 
  
  saveRDS(cid_l, file.path(cachedir, 'cid_l.rds'))
  saveRDS(pc_l, file.path(cachedir, 'pc_l.rds'))
  
} else {
  cid_l = readRDS(file.path(cachedir, 'cid_l.rds'))
  pc_l = readRDS(file.path(cachedir, 'pc_l.rds'))
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

rm(cir, chem, todo_pc)

options(warn = oldw); rm(oldw)




