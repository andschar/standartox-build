# require(webchem)
# 
# todo = c('34123-59-6', tests_fl$inchi[1:2])
# 
# token = '39221bdb-21d7-45b0-aa71-892b07f6b111'
# csid = get_csid(todo, token = token)
# 
# csid
# 
# webchem::cs_compinfo()

get_cid()


function (query, from = "name", first = FALSE, verbose = TRUE, 
          arg = NULL, ...) 
{
  foo <- function(query, from, first, verbose, ...) {
    prolog <- "https://pubchem.ncbi.nlm.nih.gov/rest/pug"
    input <- paste0("/compound/", from)
    output <- "/cids/JSON"
    if (!is.null(arg)) 
      arg <- paste0("?", arg)
    qurl <- paste0(prolog, input, output, arg)
    if (verbose) 
      message(qurl)
    Sys.sleep(0.2)
    cont <- try(content(POST(qurl, body = paste0(from, "=", 
                                                 query)), type = "text", encoding = "UTF-8"), silent = TRUE)
    if (inherits(cont, "try-error")) {
      warning("Problem with web service encountered... Returning NA.")
      return(NA)
    }
    cont <- fromJSON(cont)
    if (names(cont) == "Fault") {
      warning(cont$Fault$Details, ". Returning NA.")
      return(NA)
    }
    out <- unlist(cont)
    if (first) 
      out <- out[1]
    names(out) <- NULL
    return(out)
  }
  out <- lapply(query, foo, from = from, first = first, verbose = verbose)
  out <- setNames(out, query)
  if (first) 
    out <- unlist(out)
  return(out)
}


# own function ------------------------------------------------------------
require(httr)


token = 'zzaQIqcALsMZIWCH4z0m7PP22gqOE9hG'

qurl <- 'https://api.rsc.org/compounds/v1/filter/inchikey'
qurl <- 'https://api.rsc.org/compounds/v1/filter/name'

Sys.sleep(0.2)
cont <- try(content(POST(qurl, body = paste0(from, "=", 
                                             query)), type = "text", encoding = "UTF-8"), silent = TRUE)

#1 POST
POST(qurl, body = list(inchikey = 'YVGGHNCTFXOJCH-UHFFFAOYSA-N'))

# get queryID

#2 check if status is complete
# /filter/{queryId}/status

#3 (IF STATUS == COMPLETE) fetch results 
# /filter/{queryId}/results





