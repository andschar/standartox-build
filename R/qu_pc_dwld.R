# script to query the PubChem data base

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# data --------------------------------------------------------------------
chem = readRDS(file.path(cachedir, 'epa_chem.rds'))

drv = dbDriver("PostgreSQL")
con = dbConnect(drv, user = DBuser, dbname = DBetox, host = DBhost, port = DBport, password = DBpassword)

chem = dbGetQuery(con, "SELECT DISTINCT ON (stdinchi) stdinchi
                        FROM phch.cir")
setDT(chem)

dbDisconnect(con)
dbUnloadDriver(drv)

# debuging
if (debug_mode) {
  chem = chem[1:10]
}



# TODO script not finished



todo_inchi = chem$stdinchi
todo_inchi = gsub('inchikey=', '', todo_inchi, ignore.case = TRUE)
inchi = "InChI=1S/C12H12N2O3/c1-2-12(8-6-4-3-5-7-8)9(15)13-11(17)14-10(12)16/h3-7H,2H2,1H3,(H2,13,14,15,16,17)"








# query -------------------------------------------------------------------
## CID ----
if (online) {
  ## function
  get_cid2 = function(cas) { # enhances error catching capabilities of get_cid()
    Sys.sleep(rgamma(1, shape = 15, scale = 1/45))
    R.utils::withTimeout(
      get_cid(cas, verbose = TRUE),
      timeout = 20,
      onTimeout = 'warning'
    )
  }
  
  ## CID query
  todo_pc = sort(chem$cas)
  for (i in seq_along(todo_pc)) {
    cas = todo_pc[i]
    message('Pubchem: CAS:', cas, ' (', i, '/', length(todo_pc), ') -> to retrieve CID.')
    cid_l = get_cid(cas)
  }
  saveRDS(cid_l, file.path(cachedir, 'cid_l.rds'))
}

  dat = try(get_cid3(todo_inchi, from = 'inchikey'))
  
  'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/fastsubstructure/cid/2244/cids/XML?StripHydrogen=true'
  
  cid_l = list()
  for (i in seq_along(todo_inchi)) {
    inchi = todo_inchi[i]
    cid = get_cid3(inchi, from = 'inchikey')
    cid_l[[i]] = cid
    names(cid_l)[i] = inchi
  }

  
  res = get_cid3(todo_inchi, from = 'inchikey')
  
## Properties ----
if (online) {
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
}

## Synonyms ----
if (online) {
  pc_syn_l = list()
  for (i in seq_along(cid_l)) {
    
    qu_cas = names(cid_l)[i]
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

# log ---------------------------------------------------------------------
log_msg('PubChem download script run')

# cleaning ----------------------------------------------------------------
clean_workspace()

