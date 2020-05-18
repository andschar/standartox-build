# script to query data from WebTEST Comptox QSAR service

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# function ----------------------------------------------------------------
# TODO remove, once the function is implemented in webchem
webtest_query <- function(query,
                          from = "smiles",
                          endpoint = c("LC50",
                                       "LC50DM",
                                       "IGC50",
                                       "LD50",
                                       "BCF",
                                       "DevTox",
                                       "Mutagenicity",
                                       "BP",
                                       "VP",
                                       "MP",
                                       "Density",
                                       "FP",
                                       "ST",
                                       "TC",
                                       "Viscosity",
                                       "WS"),
                          method = c("consensus",
                                     "hc",
                                     "sm",
                                     "nn",
                                     "gc"),
                          verbose = TRUE) {
  # checks
  from <- match.arg(from)
  endpoint <- match.arg(endpoint, several.ok = TRUE)
  method <- match.arg(method)
  # vecorize
  foo <- function(query, from, endpoint, method, verbose) {
    # debuging
    # query = "CCO"; endpoint = "LC50"; from  = "smiles"; method = "hc"
    # url
    baseurl <- "https://comptox.epa.gov/dashboard/web-test"
    queryfrom <- paste0("?", from, "=", query)
    method <- paste0("method=", method)
    prolog <- paste(queryfrom, method, sep = "&")
    qurl <- file.path(baseurl, paste0(endpoint, prolog))
    # query
    if (verbose)
      message("Querying: ", query)
    Sys.sleep(rgamma(1, shape = 5, scale = 1/10))
    res <- try(
      httr::GET(qurl), silent = TRUE
    )
    if (inherits(res, "try-error")) {
      message("No result found. Returning empty entry.")
      return(data.frame(query = query, stringsAsFactors = FALSE))
    }
    if (httr::status_code(res) != 200) {
      message("No result found. Returning empty entry.")
      return(data.frame(query = query, stringsAsFactors = FALSE))
    }
    cont <- httr::content(res)
    if (!is.null(cont$predictions[[1]]$error)) { # NB for non-parseable results
      message("No result found. Returning empty entry.")
      return(data.frame(query = query, stringsAsFactors = FALSE))
    }
    # prepare
    dat_meta <- dplyr::bind_rows(cont[ names(cont) != "predictions" ])
    dat_pred <- dplyr::bind_rows(cont[ names(cont) == "predictions" ][[1]])
    # return
    out <- dplyr::bind_cols(dat_meta, dat_pred)
    out$query <- query
    out
  }
  l <- lapply(query,
              foo,
              from = from,
              endpoint = endpoint,
              method = method,
              verbose = verbose)
  # return
  dplyr::select(dplyr::bind_rows(l),
                query, dplyr::everything())
}

# data --------------------------------------------------------------------
q = "SELECT *
     FROM phch.phch_id"
phch = read_query(user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
                  query = q)
# debuging
if (debug_mode) {
  phch = phch[1:10]
}
todo = unique(phch$smiles)

# query -------------------------------------------------------------------
l = mapply(webtest_query,
           endpoint = c('LC50', 'LC50DM', 'IGC50', 'LD50'),
           MoreArgs = list(query = todo,
                           method = 'consensus'),
           SIMPLIFY = FALSE)
dt = rbindlist(l, fill = TRUE)
dt[phch, cas := i.casnr, on = c(query = 'smiles') ]

# write -------------------------------------------------------------------
saveRDS(dt, file.path(cachedir, 'comptox', 'comptox_webtest.rds'))

# log ---------------------------------------------------------------------
log_msg('QUERY: CompTox - WebTEST: download script run.')

# cleaning ----------------------------------------------------------------
clean_workspace()



