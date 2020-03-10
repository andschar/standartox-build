# API script

# setup -------------------------------------------------------------------
source('setup.R', local = FALSE)

# data --------------------------------------------------------------------
source('data.R', local = FALSE)

# description -------------------------------------------------------------
#* @apiTitle Standartox API
#* @apiDescription Retieve filtered data


# debugger ----------------------------------------------------------------
#* @filter debugger
# function(req) {
#   
#   req_envir <<- req
#   
#   plumber::forward()
# }


# filter: logger ----------------------------------------------------------
#* Log system time, request method and HTTP user agent of the incoming request
#* @filter logger
function(req) {
  log_df = data.frame(system_time = as.character(Sys.time()),
                      request_method = req$REQUEST_METHOD,
                      path_info = req$PATH_INFO,
                      http_user_agent = paste0(req$HTTP_USER_AGENT, "@", req$REMOTE_ADDR))
  fwrite(log_df, file.path(logdir, 'api', 'request.log'), append = TRUE)
  cat(paste0(unlist(log_df), collapse = '\n'))
  
  body_log = paste0(gsub('-|/|:|,|\\s+', '-', paste0(unlist(log_df[1, ]), collapse = '')), '_body.json')
  jsonlite::write_json(req$postBody, file.path(logdir, 'api', 'requests', body_log))
  
  plumber::forward()
}

# filter vers --------------------------------------------------------------
#* version path
#* @filter vers
function(req, res) {
  dirs <<- list.dirs('data', recursive = FALSE, full.names = FALSE)
  v_req = req$args$vers
  if (is.null(v_req)) {
    v <<- max(as.integer(dirs), na.rm = TRUE)
  } else {
    v <<- as.integer(gsub('\\W', '', v_req)) # sanitizing
    if (! v %in% dirs) {
      res$status = 400
      return(list(error = 'Provided version number not in data.'))
    }
  }

  plumber::forward()
}

# filter: sanitizing ------------------------------------------------------
#*
#* @filter sanitzing
function(req, res) {
  if (!is.null(req$args$cas)) {
    req$args$cas = as.integer(gsub('-|\\W', '', req$args$cas))
    chck_catalog = in_catalog(req$args$cas, catalog$casnr$variable)
    if (!is.null(chck_catalog)) {
      msg = paste0('CAS not in Standartox data base:\n', paste0(chck_catalog, collapse = '\n')) 
      res$status = 400
      return(list(error = msg))
    }
  }
  if (!is.null(req$args$concentration_type)) {
    chck_catalog = in_catalog(req$args$concentration_type, catalog$concentration_type$variable)
    if (!is.null(chck_catalog)) {
      msg = paste0('Concentration type not in Standartox data base:\n', paste0(chck_catalog, collapse = '\n'))
      res$status = 400
      return(list(error = msg))
    }
  }
  if (!is.null(req$args$chemical_role)) {
    chck_catalog = in_catalog(req$args$chemical_role, catalog$chemical_role$variable)
    if (!is.null(chck_catalog)) {
      msg = paste0('Chemical role not in Standartox data base:\n', paste0(chck_catalog, collapse = '\n'))
      res$status = 400
      return(list(error = msg))
    }
  }
  if (!is.null(req$args$chemical_class)) {
    chck_catalog = in_catalog(req$args$chemical_class, catalog$chemical_class$variable)
    if (!is.null(chck_catalog)) {
      msg = paste0('Chemical class not in Standartox data base:\n', paste0(chck_catalog, collapse = '\n'))
      res$status = 400
      return(list(error = msg))
    }
  }
  if (!is.null(req$args$taxa))  {
    chck_catalog = in_catalog(req$args$taxa, catalog$taxa$variable)
    if (!is.null(chck_catalog)) {
      msg = paste0('Taxa not in Standartox data base:\n', paste0(chck_catalog, collapse = '\n'))
      res$status = 400
      return(list(error = msg))
    }
  }
  if (!is.null(req$args$habitat)) {
    chck_catalog = in_catalog(req$args$habitat, catalog$habitat$variable)
    if (!is.null(chck_catalog)) {
      msg = paste0('Habitat value not in Standartox data base:\n', paste0(chck_catalog, collapse = '\n'))
      res$status = 400
      return(list(error = msg))
    }
  }
  if (!is.null(req$args$region)) {
    chck_catalog = in_catalog(req$args$region, catalog$region$variable)
    if (!is.null(chck_catalog)) {
      msg = paste0('Region value not in Standartox data base:\n', paste0(chck_catalog, collapse = '\n'))
      res$status = 400
      return(list(error = msg))
    }
  }
  if (!is.null(req$args$duration)) {
    req$args$duration = as.integer(gsub('\\W', '', req$args$duration)) # numeric sanitizing
    if (!all(req$args$duration %between% catalog$duration)) {
      res$status = 400
      return(list(error = 'Duration period not in Standartox data base.'))
    }
  }
  if (!is.null(req$args$effect)) {
    chck_catalog = in_catalog(req$args$effect, catalog$effect$variable)
    if (!is.null(chck_catalog)) {
      msg = paste0('Effect value not in Standartox data base:\n', paste0(chck_catalog, collapse = '\n'))
      res$status = 400
      return(list(error = msg))
    }
  }
  if (!is.null(req$args$endpoint)) {
    chck_catalog = in_catalog(req$args$endpoint, catalog$endpoint$variable)
    if (!is.null(chck_catalog)) {
      msg = paste0('Endpoint value not in Standartox data base:\n', paste0(chck_catalog, collapse = '\n'))
      res$status = 400
      return(list(error = msg))
    }
  }

  plumber::forward()
}

# endpoint: catalog -----------------------------------------------------
#* @post /catalog
#* @json
function() {
  
  return(catalog)
}

# endpoint: aggregate -----------------------------------------------------
#* @get /aggregate
#* @serializer contentType list(type="application/octet-stream")
function() {

  tmp = file.path(tempdir(), 'stx_aggregate')
  saveRDS(stx_aggregate, tmp)
  readBin(tmp, "raw", n = file.info(tmp)$size)
}

# endpoint: filter --------------------------------------------------------
#* @param:character cas
#* @param:character concentration_unit Concentration (e.g. ug/l)
#* @param:character concentration_type Concentration type (e.g. A, F)
#* @param:character chemical_role Chemical role (e.g. 'herbicide')
#* @param:character chemical_class Chemical class (e.g. 'neonicotinoid')
#* @param:character taxa taxonomic name (e.g. Algae)
#* @param:character habitat Organism habitat (e.g. freshwater)
#* @param:character region Organism geographical region (e.g. europe)
#* @param:int duration Test duration (e.g. ????)
#* @param:character effect
#* @param:character endpoint
#* @post /filter
#* @serializer contentType list(type="application/octet-stream")
function(req,
         res,
         cas = NULL,
         concentration_unit = NULL,
         concentration_type = NULL,
         chemical_role = NULL,
         chemical_class = NULL,
         taxa = NULL,
         habitat = NULL,
         region = NULL,
         duration = NULL,
         effect = NULL,
         endpoint = NULL
) {
  # function
  out = stx_filter(dt = dat,
                   cas_ = cas,
                   concentration_unit_ = concentration_unit,
                   concentration_type_ = concentration_type,
                   chemical_role_ = chemical_role,
                   chemical_class_ = chemical_class,
                   taxa_ = taxa,
                   habitat_ = habitat,
                   region_ = region,
                   duration_ = duration,
                   effect_ = effect,
                   endpoint_ = endpoint)
  # return
  if (nrow(out) == 0) {
    # TODO this should not be needed anymore once fst0.9.2 is released
    # TODO remove then
    # rbindlist(list(out, list(cas = 'No data')), fill = TRUE)
    msg = 'No data for the chosen parameter combination in the Standartox data base.'
    res$status = 400
    
    jsonlite::toJSON(msg)
  } else {
    tmp = 'tmp/data'
    fst::write_fst(out, tmp, compress = 100) # write compressed
    readBin(tmp, "raw", n = file.size(tmp)) # read to serve API request
  }
}

# endpoint: meta ----------------------------------------------------------
#* @post /meta
#* @json
function() {
  out = data.table(variable = c('accessed', 'standartox_version'),
                   value = c(as.character(Sys.time()), as.character(v)))
  
  return(out) 
}

