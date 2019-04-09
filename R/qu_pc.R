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
  ## function
  get_cid2 = function(cas) { # enhances error catching capabilities of get_cid()
    Sys.sleep(rgamma(1, shape = 15, scale = 1/45))
    R.utils::withTimeout(
      get_cid(cas, verbose = FALSE),
      timeout = 20,
      onTimeout = 'warning'
    )
  }
  
  ## CID query
  todo_pc = sort(chem$cas)
  for (i in seq_along(todo_pc)) {
    cas = todo_pc[i]
    message('Pubchem: CAS:', cas, ' (', i, '/', length(todo_pc), ') -> to retrieve CID.')
    cid_l = get_cid2(cas)
  }
  saveRDS(cid_l, file.path(cachedir, 'cid_l.rds'))

  ## properties
  pc_pro_l = list()
  for (i in seq_along(cid_l)) {
    
    qu_cas = names(cid_l[i])
    qu_cid = cid_l[[i]]
    message('Pubchem (pc_rop): CAS:', qu_cas, '; CID:', paste0(qu_cid, collapse = '\n'),
            ' (', i, '/', length(cid_l), ') -> to retrieve data.')
    
    pc_pro = try(pc_prop(qu_cid))
    if (inherits(pc_pro, 'try-error')) {
      warning('Couldn\'t retrieve CAS:', qu_cas, '; CID:', qu_cid)
      return(NA)
    }
    pc_pro_l[[i]] = pc_pro
    names(pc_pro_l)[i] = qu_cas
  }  
  saveRDS(pc_pro_l, file.path(cachedir, 'pc_pro_l.rds')) 
  
  ## synonyms
  pc_syn_l = list()
  for (i in seq_along(cid_l)) {
    
    qu_cas = names(cid_l[i])
    qu_cid = cid_l[[i]]
    message('Pubchem (pc_syn): CAS:', qu_cas, '; CID:', paste0(qu_cid, collapse = '\n'),
            ' (', i, '/', length(cid_l), ') -> to retrieve data.')
    
    pc_syn = try(pc_synonyms(qu_cid, from = 'cid'))
    if (inherits(pc_syn, 'try-error')) {
      warning('Couldn\'t retrieve CAS:', qu_cas, '; CID:', qu_cid)
      return(NA)
    }
    pc_syn_l[[i]] = unname(unlist(pc_syn))
    names(pc_syn_l)[i] = qu_cas
  }
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
pro = rbindlist(pc_pro_l, fill = TRUE, idcol = 'cas')
setnames(pro, names(pro), tolower(names(pro)))

# Synonyms
syn = sapply(pc_syn_l, `[`, 2)
syn = rbindlist(lapply(syn, as.data.frame.list),
                idcol = 'cas')
setnames(syn, 2, 'cname')
syn[ , cname := tolower(cname) ]

# merge synonyms
pc = merge(pro, syn, by = 'cas')
setcolorder(pc, c('cas', 'cid', 'cname', 'iupacname', 'inchi', 'inchikey', 'canonicalsmiles', 'isomericsmiles'))

# writing -----------------------------------------------------------------
## postgres (all data)
write_tbl(pc, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'phch', tbl = 'pubchem',
          comment = 'Results from the PubChem query')

# log ---------------------------------------------------------------------
msg = 'PubChem script run'
log_msg(msg)

# cleaning ----------------------------------------------------------------
clean_workspace()

