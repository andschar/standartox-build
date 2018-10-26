# script that queries the chemspider API with the help of the new package:
# https://github.com/NIVANorge/chemspideR
# Only 1000 requests per month are free!!

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# data --------------------------------------------------------------------
ikey = readRDS(file.path(cachedir, 'pc_inchikeys.rds'))
token = readLines(file.path(cred, 'chemspider_token.txt'))

# query -------------------------------------------------------------------
todo_cs = unlist(ikey) # TODO multiple InchiKeys per CAS
# todo_cs = todo_cs[412:425] # debuging

if (online) {
  
  cs_l = list()
  for (i in seq_along(todo_cs)) {
    
    ikey = todo_cs[i]
    cas = gsub('.InChIKey', '', names(ikey))
    qu_id = post_inchikey(inchikey = ikey, apikey = token)
    qu_status = get_status(qu_id, apikey = token)
    
    while (qu_status$status != 'Complete') {
      Sys.sleep(0.5)
      qu_status = get_status(qu_id, apikey = token)  
    }  
    if (qu_status$count == 0) break
    
    message('Chemspider: InChiKey: ', ikey, ' (', i, '/', length(todo_cs), ')')
    
    ## Results
    # CSID
    csid = get_results(qu_id, apikey = token)
    # details
    res_details = get_details(csid, apikey = token, fields = 'all', id = TRUE)
    # external references
    res_ext_ref = get_external_references(csid, apikey = token)
    
    cs_l[[i]] = list(inchikey = ikey,
                     cas = cas,
                     csid = csid,
                     details = res_details,
                     extern_ref = res_ext_ref)
    names(cs_l)[i] = ikey
  }

  saveRDS(cs_l, file.path(cachedir, 'chemspider_l2.rds'))
  
} else {
  
  cs_l = readRDS(file.path(cachedir, 'chemspider_l2.rds'))
}




