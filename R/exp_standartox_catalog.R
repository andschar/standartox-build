# script to export summary statistics to be used in shiny application

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))
v = gsub('etox', '', DBetox)

# data --------------------------------------------------------------------
header = names(read_fst(file.path(exportdir, paste0('standartox', v, '.fst')), to = 1))

# query -------------------------------------------------------------------
# cols
cols = c('cas',
         'concentration_unit',
         'concentration_type', 
         grep('cro_', header, value = TRUE),
         grep('ccl_', header, value = TRUE),
         grep('tax_', header, value = TRUE),
         grep('hab_', header, value = TRUE),
         grep('reg_', header, value = TRUE),
         'duration',
         'effect',
         'endpoint')
# loop
con = DBI::dbConnect(RPostgreSQL::PostgreSQL(),
                     dbname = DBetox,
                     host = DBhost,
                     port = DBport,
                     user = DBuser,
                     password = DBpassword)
# columns
l = list()
for (i in seq_along(cols)) {
  
  col = cols[i]
  message('Fetching: ', col)
  
  dat = summary_db_perc(con, 'standartox', 'data2', col)
  setDT(dat)
  
  l[[i]] = dat
  names(l)[i] = col
}
DBI::dbDisconnect(con)

# preparation -------------------------------------------------------------
# NOTE looks as it could be automated, however for quality checkin done by hand
# cas
cas = l$cas
setnames(cas, c('variable', 'n', 'n_total'))
cas[ , perc := ceiling(n / n_total * 100) ]
# concentration unit
concentration_unit = l$concentration_unit
setnames(concentration_unit, c('variable', 'n', 'n_total'))
concentration_unit[ , perc := ceiling(n / n_total * 100) ]
# concentration type
concentration_type = l$concentration_type
setnames(concentration_type, c('variable', 'n', 'n_total'))
concentration_type[ , perc := ceiling(n / n_total * 100) ]
# chemical class
chemical_role = rbindlist(l[ grep('cro_', names(l)) ], idcol = 'chemical_role', use.names = FALSE)
chemical_role[ , chemical_role := gsub('cro_', '', chemical_role) ]
setnames(chemical_role, c('variable', 'value', 'n', 'n_total'))
chemical_role = chemical_role[ value == 1L ]
chemical_role[ , perc := ceiling(n / n_total * 100) ]
# chemical class
chemical_class = rbindlist(l[ grep('ccl_', names(l)) ], idcol = 'chemical_class', use.names = FALSE)
chemical_class[ , chemical_class := gsub('ccl_', '', chemical_class) ]
setnames(chemical_class, c('variable', 'value', 'n', 'n_total'))
chemical_class = chemical_class[ value == 1L ]
chemical_class[ , perc := ceiling(n / n_total * 100) ]
# taxa
taxa = rbindlist(l[ grep('tax_', names(l)) ], use.names = FALSE)
setnames(taxa, c('variable', 'n', 'n_total'))
taxa = taxa[ !is.na(variable) & variable != '' ]
taxa[ , perc := ceiling(n / n_total * 100) ]
# habitat
habitat = rbindlist(l[ grep('hab_', names(l)) ], idcol = 'habitat', use.names = FALSE)
habitat[ , habitat := gsub('hab_', '', habitat) ]
setnames(habitat, c('variable', 'value', 'n', 'n_total'))
habitat = habitat[ value == 1L ]
habitat[ , perc := ceiling(n / n_total * 100) ]
# region
region = rbindlist(l[ grep('reg_', names(l)) ], idcol = 'region', use.names = FALSE)
region[ , region := gsub('reg_', '', region) ]
setnames(region, c('variable', 'value', 'n', 'n_total'))
region = region[ value == 1L ]
region[ , perc := ceiling(n / n_total * 100) ]
# duration
duration = range(l$duration$duration)
# effect
effect = l$effect
setnames(effect, c('variable', 'n', 'n_total'))
effect[ , perc := ceiling(n / n_total * 100) ]
# endpoint
endpoint = l$endpoint
setnames(endpoint, c('variable', 'n', 'n_total'))
endpoint[ , perc := ceiling(n / n_total * 100) ]
# meta
meta = melt(data.table(n_results = l$cas$n_total[1],
                       n_cas = nrow(l$cas),
                       n_concentration_unit = nrow(l$concentration_unit),
                       n_concentration_type = nrow(l$concentration_type),
                       n_chemical_role = nrow(chemical_role),
                       n_chemical_class = nrow(chemical_class),
                       n_taxa = nrow(l$tax_taxon),
                       n_habitat = nrow(habitat),
                       n_region = nrow(region),
                       n_effect = nrow(l$effect),
                       n_endpoints = nrow(l$endpoint)))

# list --------------------------------------------------------------------
catalog_l = list(cas = cas,
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
                 meta = meta)

# TODO CONTINUE HERE
# add the same information as stx_query returns
# check with /meta endpoint in API
# decide for one approach
# TODO 29.2.2020 - is this still valid?

# write -------------------------------------------------------------------
saveRDS(catalog_l, file.path(exportdir, paste0('standartox', v, '_catalog.rds')))

# log ---------------------------------------------------------------------
log_msg('EXPORT: Standartox catalog exported.')

# cleaning ----------------------------------------------------------------
clean_workspace()


