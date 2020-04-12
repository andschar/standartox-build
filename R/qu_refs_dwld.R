# script to download DOIs and other publication parameters via cross-reference

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
q = "SELECT *
     FROM ecotox.refs
     ORDER BY reference_number ASC"
refs = read_query(user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
                  query = q)
# debuging
if (debug_mode) {
  refs = refs[1:10]
}

# query -------------------------------------------------------------------
for (i in seq_along(refs$reference_number)) {
  ref = refs[i]
  # query
  message('Querying reference number: ', ref$reference_number)
  res = cr_works(query = ref$title,
                 # flq = c(query.bibliographic = refs$title,
                 #         query.bibliographic = refs$author,
                 #         query.bibliographic = refs$publication_year),
                 filter = c(`from-pub-date` = as.numeric(ref$publication_year) - 1,
                            `until-pub-date` = as.numeric(ref$publication_year) + 1),
                 limit = 5,
                 sort = 'relevance',
                 order = 'desc')
  # write
  nam = paste0(ref$reference_number, '_', to_filename(gsub('\\/', '', ref$title))) # TODO put this in to_filename()
  saveRDS(res$data, file.path(cachedir, 'crossref', nam))
}

# log ---------------------------------------------------------------------
log_msg('QUERY: CROSSREF: download script run.')

# cleaning ----------------------------------------------------------------
clean_workspace()
