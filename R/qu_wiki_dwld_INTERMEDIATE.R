# funcion to query chemical information from wikidata
# inspired by ropensci/webchem
# TODO vectorize
# TODO include it in webchem
# TODO really ugly function, rewrite

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# function ----------------------------------------------------------------
wiki_chem = function(query = NULL, identifier = 'cas') {
  baseurl = 'https://query.wikidata.org/sparql?format=json&query='
  ids = c(smiles = 'P233',
          cas = 'P231',
          cid = 'P662',
          einecs = 'P232',
          csid = 'P661',
          inchi = 'P234',
          inchikey = 'P235',
          drugbank = 'P715', 
          zvg = 'P679',
          # chebi = 'P683', # TODO leads to multiple results
          chembl = 'P592',
          unii = 'P652',
          chemical_formula = 'P274',
          echa_infocard_id = 'P2566',
          name_who = 'P2275'
          # has_role = 'P2868' # TODO leads to multiple results
          )
  
  id = ids[ match(identifier, names(ids)) ]
  
  sparql1 = paste0('PREFIX wdt: <http://www.wikidata.org/prop/direct/>\n',
                   'SELECT * WHERE { ?cas wdt:', id, '"', query, '" }')
  qurl1 = paste0(baseurl, sparql1)
  qurl1 = URLencode(qurl1)
  tmp1 = fromJSON(qurl1)
  # QID for data query
  cas1 = tmp1$results$bindings$cas$value
  if (is.null(cas1)) {
    return(data.frame(cas = query)) # TODO bad
  }
  wd = basename(cas1)
  sparql2_head = paste('PREFIX wd: <http://www.wikidata.org/entity/>',
                       'PREFIX wdt: <http://www.wikidata.org/prop/direct/>',
                       'SELECT * WHERE {')
  prop = paste0(paste0('OPTIONAL{wd:', wd, ' wdt:', ids, ' ?', names(ids), ' .}'), collapse = ' ')
  label = paste0('wd:', wd, ' rdfs:label ?label .')
  filter = 'FILTER(LANG(?label) = "en").'
  sparql2_body = paste(label, prop, filter)
  sparql2 = paste0(sparql2_head, sparql2_body, '}')
  qurl2 = paste0(baseurl, sparql2)
  qurl2 = URLencode(qurl2)
  tmp2 = fromJSON(qurl2)
  Sys.sleep(0.1)
  bindings = tmp2$results$bindings
  if (is.null(bindings) || length(bindings) == 0) {
    return(data.frame(cas = query)) # TODO bad
  }
  tmp2 = as.list(bindings) # TODO without as.list, it would return a data.frame within data.frames. Crazy!
  tmp2 = do.call(rbind, lapply(tmp2, `[`, 'value'))
  out = data.frame(label = rownames(tmp2),
                   value = tmp2$value)
  out = dcast(out, . ~ label, value.var = 'value')
  out$`.` = NULL
  
  return(out)
}

# data --------------------------------------------------------------------
drv = dbDriver("PostgreSQL")
con = dbConnect(
  drv,
  user = DBuser,
  dbname = DBetox,
  host = DBhost,
  port = DBport,
  password = DBpassword
)

chem = dbGetQuery(con, "SELECT *
                        FROM phch.cir")
setDT(chem)

dbDisconnect(con)
dbUnloadDriver(drv)

# debuging
if (debug_mode) {
  chem = chem[1:10]
}

# query -------------------------------------------------------------------
time = Sys.time()
l = list()
for (i in 1:nrow(chem)) {
  cas = chem$cas[i]
  message('Querying: ', cas, ' (', i, '/', nrow(chem), ')')
  dat = wiki_chem(cas, identifier = 'cas')  
  l[[i]] = dat
  names(l)[i] = cas
  
}
Sys.time() - time

# write -------------------------------------------------------------------
saveRDS(l, file.path(cachedir, 'wikidata2.rds'))

# log ---------------------------------------------------------------------
log_msg('WIKIDATA2 (INTERMEDIATE!): download script run.')

# cleaning ----------------------------------------------------------------
clean_workspace()

