# script to query occurrence data from the Global Biodiversity Information Facility (GBIF)

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
q = "SELECT *
     FROM taxa.taxa_id"
taxa = read_query(user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
                  query = q)
if (debug_mode) {
  taxa = taxa[1:40] # debuging here is 40 rows to be pretty sure to have habitat information returned
}

# query -------------------------------------------------------------------
todo_gbif = taxa$gbif_id
names(todo_gbif) = taxa$taxon

#! takes 1.7h for 1500 taxa
time = Sys.time()
for (i in seq_along(todo_gbif)) {
  id = todo_gbif[i]
  nam = names(todo_gbif)[i]
  message('GBIF: Querying (', i, '/', length(todo_gbif), '): ', nam)
  gbif = try(occ_search(taxonKey = id))
  # write
  saveRDS(gbif, file.path(cachedir, 'gbif', to_filename(nam, format = '.rds')))
}
Sys.time() - time

# log ---------------------------------------------------------------------
log_msg('QUERY: GBIF: download script run.')

# cleaning ----------------------------------------------------------------
clean_workspace()
