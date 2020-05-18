# script to download occurrence data identifiers from the Global Biodiversity Information Facility (GBIF)

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
q = "SELECT *
     FROM taxa.taxa_data"
taxa = read_query(user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
                  query = q)
if (debug_mode) {
  taxa = taxa[1:40] # debuging here is 40 rows to be pretty sure to have habitat information returned
}
todo = sort(unique(taxa$taxon))

# query -------------------------------------------------------------------
gbif_l = list()
for (i in seq_along(todo)) {
  taxon = todo[i]
  message('GBIF: Querying (', i, '/', length(todo), '): ', taxon)
  gbif_l[[i]] = try(name_backbone(taxon))
  names(gbif_l)[i] = taxon
}

# write -------------------------------------------------------------------
saveRDS(gbif_l, file.path(cachedir, 'gbif', 'gbif_id_l'))

# log ---------------------------------------------------------------------
log_msg('ID: GBIF: download script run.')

# cleaning ----------------------------------------------------------------
clean_workspace()

