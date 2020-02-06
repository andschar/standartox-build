# script to download wikidata identifiers

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))
source(file.path(src, 'wikidata2.R')) # TODO intermediate

# data --------------------------------------------------------------------
q = "SELECT *
     FROM ecotox.chem_id"
chem = read_query(user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
                  query = q)
# debuging
if (debug_mode) {
  chem = chem[1:40] # debuging here is 40 rows to be pretty sure to have habitat information returned
}
todo_cas = chem$cas

# query -------------------------------------------------------------------
wdid_l = get_wdid(todo_cas, identifier = 'cas')

# write -------------------------------------------------------------------
saveRDS(wdid_l, file.path(cachedir, 'wikidata', 'wdid_l.rds'))

# log ---------------------------------------------------------------------
log_msg('ID: WIKIDATA: download script run.')

# cleaning ----------------------------------------------------------------
clean_workspace()

