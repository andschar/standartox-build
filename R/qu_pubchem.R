# script to query the PubChem data base

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# data --------------------------------------------------------------------
chem = readRDS(file.path(cachedir, 'epa_chem.rds'))
# debuging
if (debug_mode) {
  chem = chem[1:10]
}

# query -------------------------------------------------------------------
if (online) {
  
  # function
  get_cid2 = function(i) { # enhances error catching capabilities of get_cid()
    cas = todo_pc[i]
    message('Pubchem: CAS:', cas, ' (', i, '/', length(todo_pc), ') -> to retrieve CID.')
    rgamma(1, shape = 15, scale = 1/45)
    R.utils::withTimeout(
      get_cid(cas, verbose = FALSE),
      timeout = 20,
      onTimeout = 'warning'
    )
  }
  # CID query
  todo_pc = sort(chem$cas)
  cid_l = sapply(seq_along(todo_pc), get_cid2)
  
  # Data query
  pc_l = list()
  for (i in seq_along(cid_l)) {
    qu_cas = names(cid_l[i])
    qu_cid = cid_l[[i]]
    message('Pubchem: CAS:', qu_cas, '; CID:', paste0(qu_cid, collapse = '\n'),
            ' (', i, '/', length(cid_l), ') -> to retrieve data.')
    
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

# save InchIKeys ----------------------------------------------------------
ikey = lapply(pc_l, `[`, 'InChIKey')
saveRDS(ikey, file.path(cachedir, 'pc_inchikeys.rds'))

# preparation -------------------------------------------------------------
# convert all entries to data.tables
# 1 col, 1 row DTs are NAs
# 1 col, >1 row DT are multiple results
pc_l = lapply(pc_l, data.table)

pc = rbindlist(pc_l, fill = TRUE, idcol = 'cas')
pc[ , V1 := NULL ] # not needed

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

msg = paste0('PubChem: For ', nrow(na_pc2_inchi), '/', nrow(pc2),
             ' CAS no InchiKeys were found.')
log_msg(msg); rm(msg)

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




