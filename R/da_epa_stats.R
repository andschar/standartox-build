# script to query the EPA data base for descriptive statistics on reported concentrations

# setup -------------------------------------------------------------------
source('R/setup.R')

# data base
DBetox = readRDS(file.path(cachedir, 'data_base_name_version.rds'))

# query -------------------------------------------------------------------
online_db = TRUE
if (online_db) {
  drv = dbDriver("PostgreSQL")
  con = dbConnect(drv, user = DBuser, dbname = DBetox, host = DBhost, port = DBport, password = DBpassword)
  
  ## filters ----
  # concentration type
  q = 'select conc1_type as conc_type, count(conc1_type) as n
       from ecotox.results
       group by conc1_type'
  coty = as.data.table(dbGetQuery(con, q))
  coty[ conc_type %in% c('NR', '--', 'NC', ''), conc_type := NA ]
  coty = coty[ , .(n = sum(n)), conc_type ]
  setorder(coty, -n)
  
  # endpoints
  q = 'select endpoint, count(endpoint) as n
       from ecotox.results
       group by endpoint'
  epts = as.data.table(dbGetQuery(con, q))
  epts[ , endpoint := gsub('/|\\*', '', endpoint) ]
  epts = epts[ , .(n = sum(n)), endpoint]
  setorder(epts, -n)
  epts[grep('50', endpoint),]; nrow(epts)
  
  # effect groups
  q = 'select effect, count(effect) as n
       from ecotox.results
       group by effect'
  effe = as.data.table(dbGetQuery(con, q))
  effe[ , effect := gsub('~|/', '', effect) ]
  effe = effe[ , .(n = sum(n)), effect]
  setorder(effe, -n)
  effe; nrow(effe)
  
  # exposure type
  q = 'select exposure_type, count(exposure_type) n
       from ecotox.tests
       group by exposure_type'
  expo = as.data.table(dbGetQuery(con, q))
  expo[ , exposure_type := gsub('/|\\*', '', exposure_type) ]
  expo = expo[ , .(n = sum(n)), exposure_type]
  setorder(expo, -n)
  expo; nrow(expo)
  
  # test dates
  q = 'select published_date, created_date, application_date
       from ecotox.tests'
  datu = as.data.table(dbGetQuery(con, q))
  cols = c('published_date', 'created_date', 'application_date')
  datu[ , (cols) := lapply(.SD, as.Date, '%m/%d/%Y'), .SDcols = cols ]
  datu[ , year := format(created_date, '%Y') ]
  datu[ , month := format(created_date, '%m') ]
  datu_agg = datu[ , .N, .(year, month)][order(year, month)]
  
  dbDisconnect(con)
  dbUnloadDriver(drv)
  
  epa_stats_l = list(coty = coty,
                     epts = epts,
                     effe = effe,
                     expo = expo,
                     datu = datu)
  
  saveRDS(epa_stats_l, file.path(cachedir, 'epa_stats_l.rds'))
  
} else {
  epa_stats_l = readRDS(file.path(cachedir, 'epa_stats_l.rds'))
}

# plots -------------------------------------------------------------------
epts = epa_stats_l[['epts']]
gg_epts = ggplot(epts[1:30], aes(y = n, x = reorder(endpoint, -n))) +
  geom_point() +
  labs(x = NULL,
       title = 'Endpoints') +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
ggsave(gg_epts, filename = file.path(plotdir, 'epts.png'),
       width = 7, height = 5)

effe = epa_stats_l[['effe']]
gg_effe = ggplot(effe[1:30], aes(y = n, x = reorder(effect, -n))) +
  geom_point() +
  labs(x = NULL,
       title = 'Effect groups') +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
ggsave(gg_effe, filename = file.path(plotdir, 'effe.png'),
       width = 7, height = 5)

expo = epa_stats_l[['expo']]
gg_expo = ggplot(expo[1:30], aes(y = n, x = reorder(exposure_type, -n))) +
  geom_point() +
  labs(x = NULL,
       title = 'Effect groups') +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
ggsave(gg_expo, filename = file.path(plotdir, 'expo.png'),
       width = 7, height = 5)

datu = epa_stats_l[['datu']]
gg_datu = ggplot(datu_agg, aes(x = year, y = N)) +
  geom_boxplot() +
  labs(x = NULL,
       title = 'Effect groups') +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
ggsave(gg_datu, filename = file.path(plotdir, 'test_datum.png'),
       width = 7, height = 5)

# Cleaning ----------------------------------------------------------------
rm(q)
