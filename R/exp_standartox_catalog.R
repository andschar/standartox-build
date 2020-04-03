# script to export summary statistics to be used in shiny application

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
q = "SELECT table_schema, table_name, column_name
     FROM information_schema.columns
     WHERE table_schema = 'standartox'
       AND table_name IN ('tests_fin', 'chemicals', 'taxa', 'refs')"
cols_db = read_query(user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
                     query = q)
cols = c('casnr',
         'cname',
         'concentration_unit',
         'concentration_type', 
         grep('cro_', cols_db$column_name, value = TRUE),
         grep('ccl_', cols_db$column_name, value = TRUE),
         grep('tax_', cols_db$column_name, value = TRUE),
         grep('hab_', cols_db$column_name, value = TRUE),
         grep('reg_', cols_db$column_name, value = TRUE),
         'duration',
         'effect',
         'endpoint',
         'exposure')
cols_db = cols_db[ column_name %in% cols ]

# query -------------------------------------------------------------------
con = DBI::dbConnect(RPostgreSQL::PostgreSQL(),
                     dbname = DBetox,
                     host = DBhost,
                     port = DBport,
                     user = DBuser,
                     password = DBpassword)
l = list()
for (i in 1:nrow(cols_db)) {
  
  col = cols_db[i]
  message('Fetching: ', paste0(col, collapse = '.'))
  
  dat = summary_db_perc(con, col$table_schema, col$table_name, col$column_name)
  
  l[[i]] = dat
  names(l)[i] = col$column_name
}
DBI::dbDisconnect(con)

# preparation -------------------------------------------------------------
# NOTE looks as it could be automated, however for quality checkin done by hand
# casnr
casnr = l$casnr
# cname
cname = l$cname
# concentration unit
concentration_unit = l$concentration_unit # TODO
# concentration type
concentration_type = l$concentration_type # TODO
# chemical class
chemical_role = rbindlist(l[ grep('cro_', names(l)) ], idcol = 'chemical_role', use.names = FALSE)
chemical_role[ , chemical_role := gsub('cro_', '', chemical_role) ]
chemical_role = chemical_role[ variable == TRUE ]
setnames(chemical_role, c('chemical_role', 'variable'), c('variable', 'value'))
setorder(chemical_role, -n)
# chemical class
chemical_class = rbindlist(l[ grep('ccl_', names(l)) ], idcol = 'chemical_class', use.names = FALSE)
chemical_class[ , chemical_class := gsub('ccl_', '', chemical_class) ]
chemical_class = chemical_class[ variable == TRUE ]
setnames(chemical_class, c('chemical_class', 'variable'), c('variable', 'value'))
setorder(chemical_class, -n)
# taxa
taxa = rbindlist(l[ grep('tax_', names(l)) ], use.names = FALSE)
taxa = taxa[ !is.na(variable) & variable != '' ]
# habitat
habitat = rbindlist(l[ grep('hab_', names(l)) ], idcol = 'habitat', use.names = FALSE)
habitat[ , habitat := gsub('hab_', '', habitat) ]
habitat = habitat[ variable == TRUE ]
setnames(habitat, c('habitat', 'variable'), c('variable', 'value'))
setorder(habitat, -n)
# region
region = rbindlist(l[ grep('reg_', names(l)) ], idcol = 'region', use.names = FALSE)
region[ , region := gsub('reg_', '', region) ]
region = region[ variable == TRUE ]
setnames(region, c('region', 'variable'), c('variable', 'value'))
setorder(region, -n)
# duration
duration = range(l$duration$variable) # TODO
# effect
effect = l$effect
# endpoint
endpoint = l$endpoint
# exposure
exposure = l$exposure
# meta
meta = transpose(data.table(n_results = l$casnr$n_total[1],
                            n_casnr = nrow(l$casnr),
                            n_cname = nrow(l$cname),
                            n_concentration_unit = nrow(l$concentration_unit),
                            n_concentration_type = nrow(l$concentration_type),
                            n_chemical_role = nrow(chemical_role),
                            n_chemical_class = nrow(chemical_class),
                            n_taxa = nrow(l$tax_taxon),
                            n_habitat = nrow(habitat),
                            n_region = nrow(region),
                            n_effect = nrow(l$effect),
                            n_endpoints = nrow(l$endpoint),
                            n_exposure = nrow(l$exposure)),
                 keep.names = 'variable')

# list --------------------------------------------------------------------
catalog_l = list(casnr = casnr,
                 cname = cname,
                 concentration_unit = concentration_unit,
                 concentration_type = concentration_type,
                 chemical_role = chemical_role,
                 chemical_class = chemical_class,
                 taxa = taxa,
                 habitat = habitat,
                 region = region,
                 duration = duration,
                 effect = effect,
                 endpoint = endpoint,
                 exposure = exposure,
                 meta = meta)

# write -------------------------------------------------------------------
saveRDS(catalog_l, file.path(exportdir, 'standartox_catalog.rds'))

# log ---------------------------------------------------------------------
log_msg('EXPORT: Standartox catalog exported.')

# cleaning ----------------------------------------------------------------
clean_workspace()


