# script to export summary statistics to be used in shiny application

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
q = "SELECT table_schema, table_name, column_name
     FROM information_schema.columns
     WHERE table_schema = 'standartox'
       AND table_name IN ('tests_fin', 'phch', 'taxa', 'refs')"
cols_db = read_query(user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
                     query = q)
cols = c('casnr',
         'cname',
         'concentration_unit',
         'concentration_type', 
         grep('cro_', cols_db$column_name, value = TRUE),
         grep('ccl_', cols_db$column_name, value = TRUE),
         grep('tax_', cols_db$column_name, value = TRUE),
         'trophic_lvl',
         grep('hab_', cols_db$column_name, value = TRUE),
         grep('reg_', cols_db$column_name, value = TRUE),
         'ecotox_grp',
         'duration',
         'effect',
         'endpoint',
         'exposure')
cols_db = cols_db[ column_name %in% cols ]

# version string ----------------------------------------------------------
vers = as.integer(list.files(appdata))
stopifnot(is.numeric(vers))

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
concentration_unit = l$concentration_unit
# concentration type
concentration_type = l$concentration_type
# chemical class
chemical_role = rbindlist(l[ grep('cro_', names(l)) ], idcol = 'chemical_role', use.names = FALSE)
chemical_role[ , chemical_role := gsub('cro_', '', chemical_role) ]
chemical_role = chemical_role[ variable == TRUE ]
chemical_role[ , variable := NULL ]
setnames(chemical_role, 'chemical_role', 'variable')
setorder(chemical_role, -n)
# chemical class
chemical_class = rbindlist(l[ grep('ccl_', names(l)) ], idcol = 'chemical_class', use.names = FALSE)
chemical_class[ , chemical_class := gsub('ccl_', '', chemical_class) ]
chemical_class = chemical_class[ variable == TRUE ]
chemical_class[ , variable := NULL ]
setnames(chemical_class, 'chemical_class', 'variable')
setorder(chemical_class, -n)
# taxa
taxa = rbindlist(l[ grep('tax_', names(l)) ], use.names = FALSE)
taxa = taxa[ !is.na(variable) & variable != '' ]
# trophic level
trophic_lvl = l$trophic_lvl
# habitat
habitat = rbindlist(l[ grep('hab_', names(l)) ], idcol = 'habitat', use.names = FALSE)
habitat[ , habitat := gsub('hab_', '', habitat) ]
habitat = habitat[ variable == TRUE ]
habitat[ , variable := NULL ]
setnames(habitat, 'habitat', 'variable')
setorder(habitat, -n)
# region
region = rbindlist(l[ grep('reg_', names(l)) ], idcol = 'region', use.names = FALSE)
region[ , region := gsub('reg_', '', region) ]
region = region[ variable == TRUE ]
region[ , variable := NULL ]
setnames(region, 'region', 'variable')
setorder(region, -n)
# ecotoxicological convenience grouping
ecotox_grp = l$ecotox_grp
# duration
duration = range(l$duration$variable) # TODO
# effect
effect = l$effect
# endpoint
endpoint = l$endpoint
# exposure
exposure = l$exposure

# list --------------------------------------------------------------------
catalog_l = list(vers = vers,
                 casnr = casnr,
                 cname = cname,
                 concentration_unit = concentration_unit,
                 concentration_type = concentration_type,
                 chemical_role = chemical_role,
                 chemical_class = chemical_class,
                 taxa = taxa,
                 trophic_lvl = trophic_lvl,
                 habitat = habitat,
                 region = region,
                 ecotox_grp = ecotox_grp,
                 duration = duration,
                 effect = effect,
                 endpoint = endpoint,
                 exposure = exposure)

# catalog shiny -----------------------------------------------------------
# add name percetnage column
catalog_l_app = copy(catalog_l)
catalog_l_app = lapply(catalog_l_app,
                       function(x) {
                         if (is.data.table(x)) {
                           x[ , name_perc := paste0(variable, ' (', perc, '%)') ]
                         } else {
                           x
                         }
                       })
# first up
cols = c('vers', 'casnr', 'concentration_unit', 'duration')
catalog_l_app[ !names(catalog_l_app) %in% cols ] = 
  lapply(catalog_l_app[ !names(catalog_l_app) %in% cols ],
         function(x) x[ , name_perc := firstup(name_perc) ])
# write -------------------------------------------------------------------
saveRDS(catalog_l, file.path(exportdir, 'standartox_catalog_api.rds'))
saveRDS(catalog_l_app, file.path(exportdir, 'standartox_catalog_app.rds'))

# log ---------------------------------------------------------------------
log_msg('EXPORT: Standartox catalog exported.')

# cleaning ----------------------------------------------------------------
clean_workspace()


