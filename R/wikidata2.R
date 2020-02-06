# funcion to query chemical information from wikidata
# inspired by ropensci/webchem
# TODO include it in webchem
# TODO handle many results per property
# TODO check wikidata time constraints
# TODO put into webchem:: once it is finished

# function ----------------------------------------------------------------
id_list <- function(type = NULL) {
  # TODO this can be extended by directly querying the list from wikidata:
  # https://www.wikidata.org/wiki/Wikidata:WikiProject_Chemistry/Properties
  # qurl <- 'SELECT ?prop ?propLabel ?datatype WHERE {
  # ?prop wdt:P31 wd:Q21294996.
  # SERVICE wikibase:label { bd:serviceParam wikibase:language "[AUTO_LANGUAGE],en". }}'
  l <- list(
    # identifiers
    c('name', 'label', 'rdfs', '@en', 'label'),
    c('cas', 'P231', 'wdt', NA, 'identifier'),
    c('ec', 'P232', 'wdt', NA, 'identifier'),
    c('smiles', 'P233', 'wdt', NA, 'identifier'),
    c('inchi', 'P234', 'wdt', NA, 'identifier'),
    c('inchikey', 'P235', 'wdt', NA, 'identifier'),
    c('einecs', 'P232', 'wdt', NA, 'identifier'),
    c('unii', 'P652', 'wdt', NA, 'identifier'),
    c('cid', 'P662', 'wdt', NA, 'identifier'), # PubChem
    c('csid', 'P661', 'wdt', NA, 'identifier'), # ChemSpider
    c('chebi', 'P683', 'wdt', NA, 'identifier'),
    c('chembl', 'P592', 'wdt', NA, 'identifier'),
    c('kegg', 'P665', 'wdt', NA, 'identifier'),
    c('dsstox', 'P3117', 'wdt', NA, 'identifier'),
    c('echa_infocard_id', 'P2566', 'wdt', NA, 'identifier'),
    c('drugbank', 'P715', 'wdt', NA, 'identifier'),
    c('zvg', 'P679', 'wdt', NA, 'identifier'),
    c('name_who', 'P2275', 'wdt', NA, 'identifier'),
    # properties
    c('standard_enthalpy_of_formation', 'P3078', 'wdt', NA, 'property'),
    c('chemical_formula', 'P274', 'wdt', NA, 'property'),
    c('refractive_index', 'P1109', 'wdt', NA, 'property'),
    c('mass', 'P2067', 'wdt', NA, 'property'),
    c('melting_point', '2101', 'wdt', NA, 'property'),
    c('boiling_point', '2102', 'wdt', NA, 'property'),
    c('decomposition_point', 'P2107', 'wdt', NA, 'property'),
    c('compustion_enthalpy', 'P2117', 'wdt', NA, 'property'),
    c('flash_point', 'P2128', 'wdt', NA, 'property'),
    c('vapor_pressure', 'P2119', 'wdt', NA, 'property'),
    c('idlh', 'P2129', 'wdt', NA, 'property'), # immediate danger to life and health
    c('density', 'P2054', 'wdt', NA, 'property'),
    c('heat_capacity', 'P2056', 'wdt', NA, 'property'),
    c('sound_speed', 'P2075', 'wdt', NA, 'property'),
    c('ionization_energy', 'P2260', 'wdt', NA, 'property')#,

#
#     c('instance_of', 'P31', 'wdt', NA, 'role'),
#     c('has_role', 'P2868', 'wdt', NA, 'role'),
#     c('part_of', 'P361', 'wdt', NA, 'role'),
#     c('has_effect', 'P1542', 'wdt', NA, 'role'),
#     c('has_quality', 'P1552', 'wdt', NA, 'role'),
#     c('use', 'P366', 'wdt', NA, 'role')
  )
  df <- data.frame(do.call(rbind, l),
                   stringsAsFactors = FALSE)
  df <- setNames(df, c('param', 'p', 'pref', 'tag', 'type'))
  if (!is.null(type))
    df <- df[ df$type %in% type, ]

  return(df)
}

# id_list <- function(type) {
  # TODO doesnt work. Weird error!
  # baseurl <- 'https://query.wikidata.org/sparql?format=json&query='
  # sparql_head <- paste('PREFIX wd: <http://www.wikidata.org/entity/>',
  #                     'PREFIX wdt: <http://www.wikidata.org/prop/direct/>')
  # qurl <- 'SELECT ?prop ?propLabel ?datatype WHERE {
  #   ?prop wdt:P31 wd:Q21294996.
  #   SERVICE wikibase:label { bd:serviceParam wikibase:language "[AUTO_LANGUAGE],en". }}'
  # qurl <- paste(baseurl, sparql_head, qurl, sep = ' ')
  # qurl <- URLencode(qurl)
  # cont <- fromJSON(simplifyDataFrame = T,
  #                  content(GET(qurl,
  #                              user_agent('webchem (https://github.com/ropensci/webchem)')), 'text'))
  # res <- as.list(cont$results$bindings)
  # df <- data.frame(p = basename(res$prop$value),
  #                  name = res$propLabel$value,
  #                  param = gsub('\\(|\\)', '', tolower(gsub('\\s+|-|/', '_', res$propLabel$value))),
  #                  pref = 'wdt',
  #                  tag = NA_character_,
  #                  type = 'all',
  #                  stringsAsFactors = FALSE)
  # 
  # return(df)
  # TODO END 
# }

sparql_build <- function(wdid, type) {
  ids <- id_list(type = type)
  baseurl <- 'https://query.wikidata.org/sparql?format=json&query='
  sparql_head <- paste('PREFIX wd: <http://www.wikidata.org/entity/>',
                       'PREFIX wdt: <http://www.wikidata.org/prop/direct/>',
                       'SELECT * WHERE {')
  label <- paste0('wd:', wdid, ' rdfs:label ?label .')
  prop <- paste0(paste0('OPTIONAL{wd:', wdid, ' wdt:', ids$p, ' ?', ids$param, ' .}'), collapse = ' ')
  filter <- 'FILTER(LANG(?label) = "en").'
  sparql_body <- paste(label, prop, filter)
  sparql <- paste0(sparql_head, sparql_body, '}')
  # URL
  qurl <- paste0(baseurl, sparql)
  qurl <- URLencode(qurl)
  
  return(qurl)
}

get_wdid <- function(query = NULL,
                     identifier = NULL,
                     verbose = TRUE) {
  foo <- function(query,
                  identifier,
                  verbose) {
    if (is.null(query))
      stop('No query argument supplied.')
    if (is.null(identifier))
      stop('No identifier argument supplied.')
    baseurl <- 'https://query.wikidata.org/sparql?format=json&query='
    ids <- id_list(type = c('label', 'identifier'))
    identifier <- match.arg(identifier, ids$param, several.ok = FALSE)
    id <- ids[ ids$param %in% identifier, ]
    # SPARQL
    param <- id$param
    p <- paste0(id$pref, ':', id$p)
    tag <- if (is.na(id$tag)) NULL
    sparql <- paste0('PREFIX wdt: <http://www.wikidata.org/prop/direct/>\n',
                     'SELECT ?', param, ' ?', param, 'Label\n',
                     'WHERE {
                        ?', param, ' ', p, ' ', '"', query, '"', tag, '.\n',
                        'SERVICE wikibase:label { bd:serviceParam wikibase:language "en". }
                      }')
    qurl <- paste0(baseurl, sparql)
    qurl <- URLencode(qurl)
    Sys.sleep(rgamma(1, shape = 15, scale = 1/10))
    if (verbose)
      message('Querying: ', query, '\n', sparql)
    cont <- fromJSON(simplifyDataFrame = T,
      content(GET(qurl,
                  user_agent('webchem (https://github.com/ropensci/webchem)')), 'text'))
    res <- as.list(cont$results$bindings) # NOTE a data.frame with list columns is returned
    if (length(res) == 0) {
      if (verbose)
        message('Substance not found! Returing NA. \n')
      out <- data.frame(query = query,
                        wdid = NA_character_,
                        label = NA_character_,
                        stringsAsFactors = FALSE)
      return(out)
    }
    out <- data.frame(query = query,
                      wdid = basename(res[[1]]$value),
                      label = res[[2]]$value,
                      stringsAsFactors = FALSE)
    return(out)
  }
  out <- lapply(query, foo, identifier = identifier, verbose = verbose)
  names(out) <- query
  return(out)
}

wd_data <- function(wdid = NULL,
                    type = c('label', 'identifier', 'property', 'role'),
                    verbose = TRUE) {
  foo <- function(wdid,
                  type,
                  verbose) {
    if (is.null(wdid))
      stop('No identifier supplied.')
    # type <- match.arg(type)
    # query
    qurl <- sparql_build(wdid, type = type)
    Sys.sleep(rgamma(1, shape = 15, scale = 1/10)) # TODO check sys sleep requirements at wikidata
    if (verbose)
      message('Querying: ', wdid, '\n', qurl)
    cont <- fromJSON(
      content(GET(qurl,
                  user_agent('webchem (https://github.com/ropensci/webchem)')), 'text'))
    res <- as.list(cont$results$bindings)
    if (length(res) == 0) {
      if (verbose)
        message('Substance not found! Returing NA. \n')
      out <- data.frame(wdid = wdid,
                        wdid = NA_character_,
                        label = NA_character_,
                        stringsAsFactors = FALSE)
      return(out)
    }
    res <- do.call(rbind, lapply(res, `[`, 'value'))
    id_l <- id_list(type = type)
    out <- data.frame(label = rownames(res),
                      value = res$value,
                      type = c('label', id_l[ id_l$param %in% rownames(res), ]$type), # NOTE UGLY BUILD!
                      stringsAsFactors = FALSE)
    out$label <- sub('\\.[0-9]+', '', out$label)
    out <- unique(out)

    return(out)
  }
  out <- lapply(wdid, foo, type = type, verbose = verbose)
  names(out) <- wdid
  return(out)
}

# query = '9041-08-1'; identifier = 'cas'  # multiple entries
# query = 'asdfsadf'; identifier = 'cas' # no entry

# query = 'WSFSSNUMVMOOMR-UHFFFAOYSA-N'; identifier = 'inchikey'
# query = 'triclosan'; identifier = 'name'
# query = '50-00-0'; identifier = 'cas' # one entry
# get_wdid(query = query, identifier = identifier, verbose = TRUE)
# wd_data('Q161210', type = 'property')
# example -----------------------------------------------------------------
# require(jsonlite)
# require(httr)
# require(data.table)
# 
# query = c('50-00-0', '1071-83-6'); identifier = 'cas'
# wdid_l = get_wdid(query = query, identifier = identifier)
# wdid_dt = rbindlist(wdid_l, idcol = 'cas')
# 
# ident_l = wd_data(wdid_dt$wdid, type = 'identifier')
# ident = rbindlist(ident_l, idcol = 'wdid')
# ident[ label == 'kegg', label := paste0(label, '_', str_extract(value, '[A-Z]+')),  ] # handle multiple KEGG
# dcast(ident, wdid ~ label, vlaue.var = 'value')
# 
# prop_l = wd_data(wdid_dt$wdid, type = 'property')
# res = rbindlist(res_l, idcol = 'wdid')
# res2 = dcast(res, wdid ~ label, value.var = 'value')
# 
# # create a function for :
# # chemical structure (P117)
# # imgae (P18)


# 
# 
# 
# 
# 
# # data --------------------------------------------------------------------
# q = "SELECT *
#      FROM cir.prop"
# chem = read_query(user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
#                   query = q)
# # debuging
# if (debug_mode) {
#   chem = chem[1:10]
# }
# 
# # query -------------------------------------------------------------------
# time = Sys.time()
# l = list()
# for (i in 1:nrow(chem)) {
#   cas = chem$cas[i]
#   message('Querying: ', cas, ' (', i, '/', nrow(chem), ')')
#   dat = wiki_chem(cas, identifier = 'cas')
#   l[[i]] = dat
#   names(l)[i] = cas
# 
# }
# Sys.time() - time
# 
# # write -------------------------------------------------------------------
# saveRDS(l, file.path(cachedir, 'wikidata2.rds'))
# 
# # log ---------------------------------------------------------------------
# log_msg('WIKIDATA2 (INTERMEDIATE!): download script run.')
# 
# # cleaning ----------------------------------------------------------------
# clean_workspace()

