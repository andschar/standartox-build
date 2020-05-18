# API script

# setup -------------------------------------------------------------------
source('~/Projects/standartox-build/app/setup.R')

# data --------------------------------------------------------------------
source(file.path(app, 'data.R'))

# catalog -----------------------------------------------------------------
catalog = readRDS(file.path(datadir2, paste0('standartox_catalog_api.rds')))

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
  dirs <<- list.dirs(file.path(app, 'data'), recursive = FALSE, full.names = FALSE)
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
  if (!is.null(req$args$casnr)) {
    req$args$casnr = as.integer(gsub('-|\\W', '', req$args$casnr)) # also safety
    chck_catalog = in_catalog(req$args$casnr, catalog$casnr$variable)
    if (!is.null(chck_catalog)) {
      msg = paste0('CAS not in Standartox database:\n',
                   paste0(chck_catalog, collapse = '\n'))
      warning(msg)
    }
  }
  if (!is.null(req$args$concentration_type)) {
    chck_catalog = in_catalog(req$args$concentration_type, catalog$concentration_type$variable)
    if (!is.null(chck_catalog)) {
      msg = paste0('Concentration type has to be one (or more) of:\n',
                   paste0(na.omit(catalog$concentration_type$variable), collapse = '\n'))
      res$status = 400
      return(list(error = msg))
    }
  }
  if (!is.null(req$args$chemical_role)) {
    chck_catalog = in_catalog(req$args$chemical_role, catalog$chemical_role$variable)
    if (!is.null(chck_catalog)) {
      msg = paste0('Chemical role has to be one (or more) of:\n',
                   paste0(sort(na.omit(catalog$chemical_role$variable)), collapse = '\n'))
      res$status = 400
      return(list(error = msg))
    }
  }
  if (!is.null(req$args$chemical_class)) {
    chck_catalog = in_catalog(req$args$chemical_class, catalog$chemical_class$variable)
    if (!is.null(chck_catalog)) {
      msg = paste0('Chemical class has to be one (or more) of:\n',
                   paste0(sort(na.omit(catalog$chemical_class$variable)), collapse = '\n'))
      res$status = 400
      return(list(error = msg))
    }
  }
  if (!is.null(req$args$taxa))  {
    chck_catalog = in_catalog(req$args$taxa, catalog$taxa$variable)
    if (!is.null(chck_catalog)) {
      msg = paste0('Taxa not in Standartox database:\n',
                   paste0(chck_catalog, collapse = '\n'))
      res$status = 400
      return(list(error = msg))
    }
  }
  if (!is.null(req$args$trophic_lvl)) {
    chck_catalog = in_catalog(req$args$trophic_lvl, catalog$trophic_lvl$variable)
    if (!is.null(chck_catalog)) {
      msg = paste0('Trophic level has to be one (or more) of:\n',
                   paste0(sort(na.omit(catalog$trophic_lvl$variable)), collapse = '\n'))
      res$status = 400
      return(list(error = msg))
    }
  }
  if (!is.null(req$args$habitat)) {
    chck_catalog = in_catalog(req$args$habitat, catalog$habitat$variable)
    if (!is.null(chck_catalog)) {
      msg = paste0('Habitat has to be one (or more) of:\n',
                   paste0(sort(na.omit(catalog$habitat$variable)), collapse = '\n'))
      res$status = 400
      return(list(error = msg))
    }
  }
  if (!is.null(req$args$region)) {
    chck_catalog = in_catalog(req$args$region, catalog$region$variable)
    if (!is.null(chck_catalog)) {
      msg = paste0('Region value has to be one (or more) of:\n',
                   paste0(sort(na.omit(catalog$region$variable)), collapse = '\n'))
      res$status = 400
      return(list(error = msg))
    }
  }
  if (!is.null(req$args$ecotox_grp)) {
    chck_catalog = in_catalog(req$args$ecotox_grp, catalog$ecotox_grp$variable)
    if (!is.null(chck_catalog)) {
      msg = paste0('Ecotox group has to be one (or more) of:\n',
                   paste0(sort(na.omit(catalog$ecotox_grp$variable)), collapse = '\n'))
      res$status = 400
      return(list(error = msg))
    }
  }
  if (!is.null(req$args$duration)) {
    req$args$duration = as.integer(gsub('\\W', '', req$args$duration)) # numeric sanitizing
    if (!all(req$args$duration %between% catalog$duration)) {
      res$status = 400
      return(list(error = 'Duration period not in Standartox database.'))
    }
  }
  if (!is.null(req$args$effect)) {
    chck_catalog = in_catalog(req$args$effect, catalog$effect$variable)
    if (!is.null(chck_catalog)) {
      msg = paste0('Effect value has to be one (or more) of:\n',
                   paste0(sort(na.omit(catalog$effect$variable)), collapse = '\n'))
      res$status = 400
      return(list(error = msg))
    }
  }
  if (!is.null(req$args$endpoint)) {
    chck_catalog = in_catalog(req$args$endpoint, catalog$endpoint$variable)
    if (!is.null(chck_catalog)) {
      msg = paste0('Endpoint value has to be one (or more) of:\n',
                   paste0(na.omit(catalog$endpoint$variable), collapse = '\n'))
      res$status = 400
      return(list(error = msg))
    }
  }
  if (!is.null(req$args$exposure)) {
    chck_catalog = in_catalog(req$args$exposure, catalog$exposure$variable)
    if (!is.null(chck_catalog)) {
      msg = paste0('Exposure value has to be one (or more) of:\n',
                   paste0(sort(na.omit(catalog$exposure$variable)), collapse = '\n'))
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

# endpoint: filter --------------------------------------------------------
#* @param:character casnr
#* @param:character concentration_unit Concentration (e.g. ug/l)
#* @param:character concentration_type Concentration type (e.g. A, F)
#* @param:character chemical_role Chemical role (e.g. 'herbicide')
#* @param:character chemical_class Chemical class (e.g. 'neonicotinoid')
#* @param:character taxa taxonomic name (e.g. Algae)
#* @param:character trophic_lvl Trophic level (e.g. autotroph)
#* @param:character habitat Organism habitat (e.g. freshwater)
#* @param:character region Organism geographical region (e.g. europe)
#* @param:character ecotox_grp Ecotoxicological organism group (e.g. Fish)
#* @param:int duration Test duration (e.g. c(24, 48))
#* @param:character effect
#* @param:character endpoint
#* @param:character exposure
#* @post /filter
#* @serializer contentType list(type="application/octet-stream")
function(req,
         res,
         casnr = NULL,
         concentration_unit = NULL,
         concentration_type = NULL,
         chemical_role = NULL,
         chemical_class = NULL,
         taxa = NULL,
         trophic_lvl = NULL,
         habitat = NULL,
         region = NULL,
         ecotox_grp = NULL,
         duration = NULL,
         effect = NULL,
         endpoint = NULL,
         exposure = NULL
) {
  # function
  out = stx_filter(test = stx_test,
                   chem = stx_chem,
                   taxa = stx_taxa,
                   refs = stx_refs,
                   casnr_ = casnr,
                   concentration_unit_ = concentration_unit,
                   concentration_type_ = concentration_type,
                   chemical_role_ = chemical_role,
                   chemical_class_ = chemical_class,
                   taxa_ = taxa,
                   trophic_lvl_ = trophic_lvl,
                   habitat_ = habitat,
                   region_ = region,
                   ecotox_grp_ = ecotox_grp,
                   duration_ = duration,
                   effect_ = effect,
                   endpoint_ = endpoint,
                   exposure_ = exposure)
  # return
  tmp = file.path(tempdir(), 'data')
  fst::write_fst(out, tmp, compress = 100) # write compressed
  readBin(tmp, 'raw', n = file.size(tmp)) # read to serve API request
}

# endpoint: meta ----------------------------------------------------------
#* @post /meta
#* @json
function() {
  data.table(variable = c('accessed', 'standartox_version'),
             value = c(as.character(Sys.time()), as.character(v)))
}

# endpoint: chem ----------------------------------------------------------
#* @get /chem
#* @serializer contentType list(type="application/octet-stream")
function() {
  fl = file.path(datadir2, 'standartox.phch.fst')
  readBin(fl,
          'raw',
          n = file.size(fl))
}

# endpoint: taxa ----------------------------------------------------------
#* @get /taxa
#* @serializer contentType list(type="application/octet-stream")
function() {
  fl = file.path(datadir2, 'standartox.taxa.fst')
  readBin(fl,
          'raw',
          n = file.size(fl))
}




