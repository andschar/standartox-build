# script to query the PubChem data base

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))
source('/home/scharmueller/Projects/etox-base/R/PUBCHEM_HTTP_PROBLEM.R')

# data --------------------------------------------------------------------
drv = dbDriver("PostgreSQL")
DBetox = 'etox20190314'
con = dbConnect(drv, user = DBuser, dbname = DBetox, host = DBhost, port = DBport, password = DBpassword)

chem = dbGetQuery(con, "SELECT DISTINCT ON (inchikey) inchikey
                        FROM phch.cir")
setDT(chem)

dbDisconnect(con)
dbUnloadDriver(drv)

# debuging
if (debug_mode) {
  chem = chem[1:10]
}

inchikey = chem$inchikey
inchikey = gsub('InChIKey=', '', inchikey) # TODO remove in future

# query -------------------------------------------------------------------
## CIDs
if (online) {
  cid_l = get_cid(inchikey, from = 'inchikey', verbose = TRUE)
  
  saveRDS(cid_l, file.path(cachedir, 'cid_l.rds'))
} else {
  
  cid_l = readRDS(file.path(cachedir, 'cid_l.rds'))
}

## Properties
if (online) {
  time = Sys.time()
  pc_prop = pc_prop(unlist(cid_l))
  Sys.time() - time
  
  saveRDS(pc_prop, file.path(cachedir, 'pc_prop.rds'))
} else {
  
  pc_prop = readRDS(file.path(cachedir, 'pc_prop.rds'))
}

## Synonyms
if (online) {
  time = Sys.time()
  pc_syn_l = pc_synonyms(inchikey, from = 'inchikey')
  Sys.time() - time

  saveRDS(pc_syn_l, file.path(cachedir, 'pc_syn_l.rds'))
} else {
  
  pc_syn_l = readRDS(file.path(cachedir, 'pc_syn_l.rds'))
}

# log ---------------------------------------------------------------------
log_msg('PubChem download script run')

# cleaning ----------------------------------------------------------------
clean_workspace()


# OLD ---------------------------------------------------------------------
# 
# 
#   
#   
#   
#   # ERROR cid_l2 = webchem::get_cid(todo_inchi, from = 'inchikey', verbose = TRUE)
#   #  ERROR cid_l3 = webchem::get_cid(todo_inchi[5], from = 'inchikey', verbose = TRUE)
#   
#   prop_l = pc_prop()
#   prop_l2 = webchem::pc_prop()
#   
#   syn_l = pc_synonyms(todo_inchi, from = 'inchikey')
#   syn_l2 = webchem::pc_synonyms(todo_inchi, from = 'inchikey')
#   
#   
#   
#   
#   saveRDS()
# 
#   test_syn = pc_synonyms()
# 
# 
# # query -------------------------------------------------------------------
# ## CID ----
# if (online) {
#   ## function
#   get_cid2 = function(cas) { # enhances error catching capabilities of get_cid()
#     Sys.sleep(rgamma(1, shape = 15, scale = 1/45))
#     R.utils::withTimeout(
#       get_cid(cas, verbose = TRUE),
#       timeout = 20,
#       onTimeout = 'warning'
#     )
#   }
#   
#   ## CID query
#   cid_l = list()
#   for (i in seq_along(todo_inchi)) {
#     todo = todo_pc[i]
#     message('Pubchem: CAS:', todo, ' (', i, '/', length(todo_pc), ') -> to retrieve CID.')
#     cid_l = get_cid(todo, from = 'inchi', verbose = TRUE)
#   }
#   saveRDS(cid_l, file.path(cachedir, 'cid_l.rds'))
# }
# 
#   dat = try(get_cid3(todo_inchi, from = 'inchikey'))
#   
#   'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/fastsubstructure/cid/2244/cids/XML?StripHydrogen=true'
#   
#   cid_l = list()
#   for (i in seq_along(todo_inchi)) {
#     inchi = todo_inchi[i]
#     cid = get_cid3(inchi, from = 'inchikey')
#     cid_l[[i]] = cid
#     names(cid_l)[i] = inchi
#   }
# 
#   
#   res = get_cid3(todo_inchi, from = 'inchikey')
#   
# ## Properties ----
# if (online) {
#   ## properties
#   pc_pro_l = list()
#   for (i in seq_along(cid_l)) {
#     
#     qu_cas = names(cid_l[i])
#     qu_cid = cid_l[[i]]
#     message('Pubchem (pc_rop): CAS:', qu_cas, '; CID:', paste0(qu_cid, collapse = '\n'),
#             ' (', i, '/', length(cid_l), ') -> to retrieve data.')
#     
#     pc_pro = try(pc_prop(qu_cid))
#     if (inherits(pc_pro, 'try-error')) {
#       warning('Couldn\'t retrieve CAS:', qu_cas, '; CID:', qu_cid)
#       return(NA)
#     }
#     pc_pro_l[[i]] = pc_pro
#     names(pc_pro_l)[i] = qu_cas
#   }  
#   saveRDS(pc_pro_l, file.path(cachedir, 'pc_pro_l.rds')) 
# }
# 
# ## Synonyms ----
# if (online) {
#   pc_syn_l = list()
#   for (i in seq_along(cid_l)) {
#     
#     qu_cas = names(cid_l)[i]
#     qu_cid = cid_l[[i]]
#     message('Pubchem (pc_syn): CAS:', qu_cas, '; CID:', paste0(qu_cid, collapse = '\n'),
#             ' (', i, '/', length(cid_l), ') -> to retrieve data.')
#     
#     pc_syn = try(pc_synonyms(qu_cid, from = 'cid'))
#     if (inherits(pc_syn, 'try-error')) {
#       warning('Couldn\'t retrieve CAS:', qu_cas, '; CID:', qu_cid)
#       return(NA)
#     }
#     pc_syn_l[[i]] = unname(unlist(pc_syn))
#     names(pc_syn_l)[i] = qu_cas
#   }
#   saveRDS(pc_syn_l, file.path(cachedir, 'pc_syn_l.rds'))
#   
# } else {
#   cid_l = readRDS(file.path(cachedir, 'cid_l.rds'))
#   pc_pro_l = readRDS(file.path(cachedir, 'pc_pro_l.rds'))
#   pc_syn_l = readRDS(file.path(cachedir, 'pc_syn_l.rds'))
# }
# 
# # save InchIKeys ----------------------------------------------------------
# ikey = lapply(pc_pro_l, `[`, 'InChIKey')
# saveRDS(ikey, file.path(cachedir, 'pc_inchikeys.rds'))


