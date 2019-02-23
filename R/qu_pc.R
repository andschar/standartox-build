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
  pc_pro_l = list()
  pc_syn_l = list()
  for (i in seq_along(cid_l)) {
    qu_cas = names(cid_l[i])
    qu_cid = cid_l[[i]]
    message('Pubchem: CAS:', qu_cas, '; CID:', paste0(qu_cid, collapse = '\n'),
            ' (', i, '/', length(cid_l), ') -> to retrieve data.')
    
    pc_pro = pc_prop(qu_cid, verbose = FALSE)
    pc_syn = pc_synonyms(qu_cid, from = 'cid')
    
    pc_pro_l[[i]] = pc_pro
    names(pc_pro_l)[i] = qu_cas
    pc_syn_l[[i]] = unname(unlist(pc_syn))
    names(pc_syn_l)[i] = qu_cas
  } 
  
  saveRDS(cid_l, file.path(cachedir, 'cid_l.rds'))
  saveRDS(pc_pro_l, file.path(cachedir, 'pc_pro_l.rds'))
  saveRDS(pc_syn_l, file.path(cachedir, 'pc_syn_l.rds'))
  
} else {
  cid_l = readRDS(file.path(cachedir, 'cid_l.rds'))
  pc_pro_l = readRDS(file.path(cachedir, 'pc_pro_l.rds'))
  pc_syn_l = readRDS(file.path(cachedir, 'pc_syn_l.rds'))
}

# save InchIKeys ----------------------------------------------------------
ikey = lapply(pc_pro_l, `[`, 'InChIKey')
saveRDS(ikey, file.path(cachedir, 'pc_inchikeys.rds'))

# preparation -------------------------------------------------------------
# convert all entries to data.tables
# 1 col, 1 row DTs are NAs
# 1 col, >1 row DT are multiple results
pc_pro_l = lapply(pc_pro_l, data.table)

pc = rbindlist(pc_pro_l, fill = TRUE, idcol = 'cas')[ , V1 := NULL ]
setnames(pc, names(pc), tolower(names(pc)))

# Synonyms
syn = sapply(pc_syn_l, `[`, 2)
syn = rbindlist(lapply(syn, as.data.frame.list),
                idcol = 'cas')
setnames(syn, 2, 'cname')
syn[ , cname := tolower(cname) ]

# merge synonyms
pc = merge(pc, syn, by = 'cas')
setcolorder(pc, c('cas', 'cid', 'cname', 'iupacname', 'inchi', 'inchikey', 'canonicalsmiles', 'isomericsmiles'))

# final dt ----------------------------------------------------------------
# https://pubchemdocs.ncbi.nlm.nih.gov/about
# CID - non-zero integer PubChem ID
# XLogP - Log P calculated Log P
pc_fin = pc[ , .SD, .SDcols = c('cas', 'cid', 'cname', 'inchikey', 'canonicalsmiles', 'isomericsmiles', 'iupacname', 'exactmass')]
pc_fin = pc_fin[!duplicated(cas)] #! easy way out, although pubchem doesn't provide important information
setnames(pc_fin, names(pc_fin), paste0('pc_', names(pc_fin)))

# missing entries ---------------------------------------------------------
na_pc_fin_inchi = pc_fin[ is.na(pc_inchikey) ]

msg = paste0('PubChem: For ', nrow(na_pc_fin_inchi), '/', nrow(pc_fin),
             ' CAS no InchiKeys were found.')
log_msg(msg); rm(msg)

if (nrow(na_pc_fin_inchi) > 0) {
  fwrite(na_pc_fin_inchi, file.path(missingdir, 'na_pc_fin_inchi.csv'))
  message('Writing missing data to:\n',
          file.path(missingdir, 'na_pc_fin_inchi.csv'))
}

# names -------------------------------------------------------------------
setnames(pc_fin, tolower(names(pc_fin)))
setnames(pc_fin, 'pc_cas', 'cas')

# writing -----------------------------------------------------------------
## rds
saveRDS(pc_fin, file.path(cachedir, 'pc_fin.rds'))
## postgres (all data)
write_tbl(pc, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'phch', tbl = 'pubchem',
          comment = 'Results from the PubChem query')

# log ---------------------------------------------------------------------
msg = 'PubChem script run'
log_msg(msg)

# cleaning ----------------------------------------------------------------
clean_workspace()

