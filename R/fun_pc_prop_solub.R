# script to download additional chemical parameters from PubChem
# that are not yet available through webchem:: but PUG VIEW 
# contains mainly 3rd party data
# https://pubchemdocs.ncbi.nlm.nih.gov/pug-view
# TODO half-finished
# TODO as an extension to webchem:: ? 

# setup -------------------------------------------------------------------
require(httr)
require(jsonlite)

# debuging
# cid <- c('5564', '7843'); verbose = TRUE
# cid = 5564

pc_prop2 <- function(cid, properties = NULL, verbose = TRUE, ...) {
  napos <- which(is.na(cid))
  cid_o <- cid
  cid <- cid[!is.na(cid)]
  
  out_l <- list()
  for (i in seq_along(cid)) {
    id = cid[i]
    prolog <- 'https://pubchem.ncbi.nlm.nih.gov/rest/pug_view'
    input <- paste0('/data/compound/', id)
    output <- '/JSON?heading=Solubility'
  
    qurl <- paste0(prolog, input, output)
    if (verbose)
      message(qurl)
    
    Sys.sleep(0.2)
    
    cont <- try(content(GET(qurl), type = 'text', encoding = 'UTF-8'), silent = TRUE)
    if (inherits(cont, "try-error")) {
      warning('Problem with web service encountered... Returning NA.')
      return(NA)
    }
    cont <- fromJSON(cont, simplifyDataFrame = FALSE)
    if (names(cont) == 'Fault') {
      warning(cont$Fault$Details, '. Returning NA.')
      return(NA)
    }
  
    out <- sapply(cont$Record$Section[[1]]$Section[[1]]$Section[[1]]$Information, '[', 'StringValue')  
    
    out_l[[i]] <- out
    names(out_l)[i] <- id
  }
  
  return(out_l)
}

test = pc_prop2(cid)



