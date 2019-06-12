get_csid2 <- function(query, from = 'name', apikey = NULL,
                      orderBy = "recordId", orderDirection = "ascending", ...) {
  if (is.null(apikey)) {
    stop('Please supply an apikey')
  }
  
  orderBy_values <- c(
    "recordId", "massDefect", "molecularWeight",
    "referenceCount", "dataSourceCount", "pubMedCount",
    "rscCount"
  )
  orderDirection_values <- c("ascending", "descending")
  if (orderBy %in% orderBy_values == FALSE) stop("Invalid argument: orderBy")
  if (orderDirection %in% orderDirection_values == FALSE) {
    stop("Invalid argument: orderDirection")
  }
  
  
  # from can be name | inchi | inchikey | smiles | formula | mass
  prolog <- 'https://api.rsc.org/compounds/v1/filter/'
  qurl <- paste0(prolog, from)
  
  if (from == 'name') {
    body <- list(
      "name" = query,
      "orderBy" = orderBy,
      "orderDirection" = orderDirection
    )
  }
  if (from == 'inchikey') {
    body <- list(
      "inchikey" = query
    )
  }
  if (from == 'inchi') {
    body <- list(
      "inchi" = query
    )
  }
  if (from == 'smiles') {
    body <- list(
      "smiles" = query
    )
  }
  headers <- c("Content-Type" = "", "apikey" = apikey)
  body <- jsonlite::toJSON(body, auto_unbox = TRUE)
  postres <- httr::POST(
    url = qurl,
    httr::add_headers(.headers = headers),
    body = body
  )
  #saveRDS(postres, '/tmp/postres.rds')
  # "https://api.rsc.org/compounds/v1/filter/name"
  if (postres$status_code == 200) {
    queryId <- jsonlite::fromJSON(rawToChar(postres$content))$queryId
  }
  status <- 'not complete'
  while(status != 'Complete') {
    status <- httr::GET(
      url <- paste0(prolog, queryId, "/status"),
      httr::add_headers(.headers = headers)
    )
    status <- jsonlite::fromJSON(httr::content(status, type = 'text', encoding = 'UTF-8'))$status
  }
  res <- httr::GET(
    url <- paste0(prolog, queryId, "/results"),
    httr::add_headers(.headers = headers)
  )
  out <- jsonlite::fromJSON(httr::content(res, type = 'text', encoding = 'UTF-8'))
  
  return(out)
}