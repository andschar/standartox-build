# API script

# setup -------------------------------------------------------------------
source('setup.R', local = FALSE)

# description -------------------------------------------------------------
#* @apiTitle Standartox API
#* @apiDescription Retieve filtered data


# debugger ----------------------------------------------------------------
#* @filter debugger
function(req) {
  
  req_envir <<- req
  
  plumber::forward()
}


# filter: logger ----------------------------------------------------------
#* Log system time, request method and HTTP user agent of the incoming request
#* @filter logger
function(req) {
  log_df = data.frame(system_time = as.character(Sys.time()),
                      request_method = req$REQUEST_METHOD,
                      path_info = req$PATH_INFO,
                      http_user_agent = paste0(req$HTTP_USER_AGENT, "@", req$REMOTE_ADDR))
  fwrite(log_df, 'request.log', append = TRUE)
  cat(paste0(unlist(log_df), collapse = '\n'))
  
  body_log = paste0(gsub('-|/|:|,|\\s+', '-', paste0(unlist(log_df[1, ]), collapse = '')), '_body.json')
  jsonlite::write_json(req$postBody, file.path('log', body_log))
  
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

# filter: catalog ---------------------------------------------------------
#*
#* @filter catalog
function(req) {
  catal <<- readRDS(file.path('data',
                              v,
                              paste0('standartox', v, '_catalog.rds')))
  catal$vers <<- dirs
  
  plumber::forward()
}

# filter: sanitizing ------------------------------------------------------
#*
#* @filter sanitzing
function(req, res) {
  if (!is.null(req$args$cas)) {
    req$args$cas = as.integer(gsub('-|\\W', '', req$args$cas))
    chck_catal = in_catalog(req$args$cas, catal$cas$variable)
    if (!is.null(chck_catal)) {
      msg = paste0('CAS not in Standartox data base:\n', paste0(chck_catal, collapse = '\n')) 
      res$status = 400
      return(list(error = msg))
    }
  }
  if (!is.null(req$args$concentration_type)) {
    chck_catal = in_catalog(req$args$concentration_type, catal$concentration_type$variable)
    if (!is.null(chck_catal)) {
      msg = paste0('Concentration type not in Standartox data base:\n', paste0(chck_catal, collapse = '\n'))
      res$status = 400
      return(list(error = msg))
    }
  }
  if (!is.null(req$args$chemical_class)) {
    chck_catal = in_catalog(req$args$chemical_class, catal$chemical_class$variable)
    if (!is.null(chck_catal)) {
      msg = paste0('Chemical class not in Standartox data base:\n', paste0(chck_catal, collapse = '\n'))
      res$status = 400
      return(list(error = msg))
    }
  }
  if (!is.null(req$args$taxa))  {
    chck_catal = in_catalog(req$args$taxa, catal$taxa$variable)
    if (!is.null(chck_catal)) {
      msg = paste0('Taxa not in Standartox data base:\n', paste0(chck_catal, collapse = '\n'))
      res$status = 400
      return(list(error = msg))
    }
  }
  if (!is.null(req$args$habitat)) {
    chck_catal = in_catalog(req$args$habitat, catal$habitat$variable)
    if (!is.null(chck_catal)) {
      msg = paste0('Habitat value not in Standartox data base:\n', paste0(chck_catal, collapse = '\n'))
      res$status = 400
      return(list(error = msg))
    }
  }
  if (!is.null(req$args$region)) {
    chck_catal = in_catalog(req$args$region, catal$region$variable)
    if (!is.null(chck_catal)) {
      msg = paste0('Region value not in Standartox data base:\n', paste0(chck_catal, collapse = '\n'))
      res$status = 400
      return(list(error = msg))
    }
  }
  if (!is.null(req$args$duration)) {
    req$args$duration = as.integer(gsub('\\W', '', req$args$duration)) # numeric sanitizing
    if (!all(req$args$duration %between% catal$duration)) {
      res$status = 400
      return(list(error = 'Duration period not in Standartox data base.'))
    }
  }
  if (!is.null(req$args$effect)) {
    chck_catal = in_catalog(req$args$effect, catal$effect$variable)
    if (!is.null(chck_catal)) {
      msg = paste0('Effect value not in Standartox data base:\n', paste0(chck_catal, collapse = '\n'))
      res$status = 400
      return(list(error = msg))
    }
  }
  if (!is.null(req$args$endpoint)) {
    chck_catal = in_catalog(req$args$endpoint, catal$endpoint$variable)
    if (!is.null(chck_catal)) {
      msg = paste0('Endpoint value not in Standartox data base:\n', paste0(chck_catal, collapse = '\n'))
      res$status = 400
      return(list(error = msg))
    }
  }

  plumber::forward()
}

# filter: prefix ----------------------------------------------------------
#* add prefixes to certain arguments
#* @filter prefix
function(req) {
  if (!is.null(req$args$chemical_class))
    req$args$chemical_class = paste0('ccl_', req$args$chemical_class)
  if (!is.null(req$args$habitat))
    req$args$habitat = paste0('hab_', req$args$habitat)
  if (!is.null(req$args$region))
    req$args$region = paste0('reg_', req$args$region)
  
  plumber::forward()
}

# endpoint: catalog -----------------------------------------------------
#* @post /catalog
#* @json
function() {
  
  return(catal)
}

# endpoint: st_aggregate --------------------------------------------------
#* @get /aggregate
#* @serializer contentType list(type="application/octet-stream")
function() {

  tmp = file.path(tempdir(), 'stx_aggregate')
  saveRDS(stx_aggregate, tmp)
  readBin(tmp, "raw", n = file.info(tmp)$size)
}

# endpoint: data: rds -----------------------------------------------------
#* @param:character cas
#* @param:character concentration_type:character Concentration type (e.g. 'A', 'F')
#* @param:character chemical_class Chemical class (e.g. 'herbicide')
#* @param:character taxa taxonomic name (e.g. Algae)
#* @param:character habitat Organism habitat (e.g. freshwater)
#* @param:character region Organism geographical region (e.g. europe)
#* @param:int duration Test duration (e.g. ????)
#* @param:character effect
#* @param:character endpoint
#* @post /filter/rds
#* @serializer contentType list(type="application/octet-stream")
function(req,
         res,
         cas = NULL,
         concentration_type = NULL,
         chemical_class = NULL,
         taxa = NULL,
         habitat = NULL,
         region = NULL,
         duration = NULL,
         effect = NULL,
         endpoint = NULL
         # publ_year = publ_year, # NOTE possible addition
         # acch = acch, # NOTE possible addition
         # exposure = exposure, # NOTE possible addition
) {
  # data
  dat = fst::read_fst(file.path('data',
                                v,
                                paste0('standartox', v, '.fst')),
                      as.data.table = TRUE)
  # function
  out = stx_filter(dt = dat,
                   cas_ = cas,
                   concentration_type_ = concentration_type,
                   chemical_class_ = chemical_class,
                   taxa_ = taxa,
                   habitat_ = habitat,
                   region_ = region,
                   duration_ = duration,
                   effect_ = effect,
                   endpoint_ = endpoint)
  # return
  if (nrow(out) == 0) {
    # TODO raise issue for fst to allow nrow(out) == 0 to be saved to disk
    # rbindlist(list(out, list(cas = 'No data')), fill = TRUE)
    msg = 'No data for the chosen parameter combination in the Standartox data base.'
    res$status = 400
    
    jsonlite::toJSON(msg)
  } else {
    time = Sys.time()
    tmp = file.path(tempdir(), 'data')
    fst::write_fst(out, tmp, compress = 100)
    write_speed = Sys.time() - time
    logger_write_speed = data.frame(date = Sys.time(),
                                    time = write_speed)
    fwrite(logger_write_speed, 'write_speed.log', append = TRUE)
    cat('\n', tmp)
    
    readBin(tmp, "raw", n = file.size(tmp))
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

