# script that queries the chemspider API with the help of the new package:
# https://github.com/NIVANorge/chemspideR



# NOT VERY NEW DATA CAN BE SCRAPED





# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# data --------------------------------------------------------------------
ikey = readRDS(file.path(cachedir, 'pc_inchikeys.rds'))
token = readLines(file.path(cred, 'chemspider_token.txt'))

# query -------------------------------------------------------------------
todo_cs = unlist(ikey) # TODO multiple InchiKeys per CAS
todo_cs = todo_cs[423:425] # debuging

for (i in seq_along(todo_cs)) {
  
  ikey = todo_cs[i]
  qu_id = post_inchikey(inchikey = ikey, apikey = token)
  qu_status = get_status(qu_id, apikey = token)

  if (qu_status$status == 'Complete') {
    csid = get_results(qu_id, apikey = token)
  }
  
  res_details = get_details(csid, apikey = token)
  res_ext_ref = get_external_references(csid, token)
  res_mol = get_mol(csid, token)
  paste0(res_mol, collapse = '\n')
  res_data_src = get_data_sources(token)
  get_sdf(qu_id, token)
}

write_mol(res_mol, file = '/tmp/test.mol')




chemspideR::get_status() 	



chemspideR::get_results()