# script to export summary statistics to be used in shiny application

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))
v = gsub('etox', '', DBetox)

# data --------------------------------------------------------------------
header = names(read_fst(file.path(exportdir, v, paste0('standartox', v, '.fst')), to = 1))

# query -------------------------------------------------------------------
# cols
cols = c('effect', 'endpoint', 'conc1_type', 'test_location', 'obs_duration_mean2',
         grep('hab_', header, value = TRUE),
         grep('reg_', header, value = TRUE),
         grep('ccl_', header, value = TRUE))
# loop
l = list()
for (i in seq_along(cols)) {
  
  col = cols[i]
  message('Fetching: ', col)
  con = DBI::dbConnect(RPostgreSQL::PostgreSQL(),
                       dbname = DBetox,
                       host = DBhost,
                       port = DBport,
                       user = DBuser,
                       password = DBpassword)
  dat = summary_db_perc(con, 'standartox', 'data2', col)
  setDT(dat)
  
  l[[i]] = dat
  names(l)[i] = col
}

# preparation -------------------------------------------------------------
stat = rbindlist(l, idcol = TRUE)
setnames(stat, c('variable', 'value', 'n', 'n_tot'))
stat = stat[ !is.na(value) ]
stat[ value == '1', value := variable ]
stat[ , name := firstup(gsub('^([a-z]{3}_)', '', value)) ]
stat[ name == 'America_north', name := 'North America' ]
stat[ name == 'America_south', name := 'South America' ]
stat[ grep('hab_', variable), variable := 'habitat' ]
stat[ grep('reg_', variable), variable := 'region' ]
stat[ grep('ccl_', variable), variable := 'chemical_class' ]
stat[ , name_perc := paste0(name, ' (', round(n / n_tot * 100), '%)') ]
stat_l = split(stat, stat$variable)

stat_l$obs_duration_mean2 = stat_l$obs_duration_mean2[ , range(na.omit(as.numeric(value))) ]

# write -------------------------------------------------------------------
saveRDS(stat_l, file.path(exportdir, v, paste0('standartox', v, '_shiny_stats.rds')))
save(stat_l, file = file.path(exportdir, v, paste0('standartox', v, '_shiny_stats.rda'))) # for standartox::

# log ---------------------------------------------------------------------
log_msg('Export: application summary stats exported')

# cleaning ----------------------------------------------------------------
clean_workspace()


