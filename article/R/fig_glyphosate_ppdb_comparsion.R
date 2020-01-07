# script to load data for PPDB - Standartox comparison
#! similar to ./talk/talk_data_oncor_mykiss.R
# TODO add names

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))
tax = 'Daphnia' # 'Oncorhynchus'
dur = c(24,96)

# query -------------------------------------------------------------------
q1 = paste0("SELECT stn.cas AS casnr, stn.cname, stn.concentration, stn.concentration_unit, stn.duration, stn.duration_unit, stn.tax_taxon
             FROM standartox.data2 stn
             WHERE stn.endpoint = 'XX50'")

q2 = paste0("SELECT *
             FROM ppdb.data")

drv = dbDriver("PostgreSQL")
con = dbConnect(drv, user = DBuser, dbname = DBetox, host = DBhost, port = DBport, password = DBpassword)

stn = dbGetQuery(con, q1)
setDT(stn)
stn[ , casnr := as.character(casnr) ]

ppdb = dbGetQuery(con, q2)
setDT(ppdb)
ppdb[ , casnr := as.character(casnr) ]
ppdb[ , value := value * 1000 ] # ppm to ppb
edpt = c('XX50', 'LC50', 'EC50', 'LD50')
ppdb = ppdb[ endpoint %in% edpt &
               grepl(tax, taxon) ]

dbDisconnect(con)
dbUnloadDriver(drv)

# preparation ------------------------------------------------------------
## Standartox
stn2 = stn[ grep(tax, tax_taxon) ] %>% 
  .[ concentration %between% dur ] %>% 
  .[ concentration_unit %in% c('ug/l', 'ppb') ]
ppdb_cas = unique(ppdb$casnr)
todo_cas = stn2[ casnr %in% ppdb_cas, .N, casnr ][ order(-N) ][ , casnr][ 1:20 ]
stn2 = stn2[ casnr %in% todo_cas ]
# agg
stn2_agg = stn2[ ,
                 .(gm = gm_mean(concentration)),
                 .(casnr) ]
## PPDB
ppdb2 = ppdb[ casnr %in% stn2$casnr ]

# merge -------------------------------------------------------------------
stn2[ppdb2, cname2 := i.cname, on = 'casnr' ]
stn2_agg[ppdb2, cname2 := i.cname, on = 'casnr' ]

# plot --------------------------------------------------------------------
gg = ggplot() +
  geom_point(data = stn2_agg, aes(y = reorder(cname2, -gm), gm),
             size = 0.000001) +
  geom_point(data = stn2, aes(y = cname2, x = concentration, col = 'EPA ECOTOX'),
             size = 0.5, show.legend = TRUE) +
  geom_point(data = stn2_agg, aes(y = cname2, x = gm, col = 'Standartox'),
             size = 4) +
  geom_point(data = ppdb2, aes(y = cname, x = value, col = 'PPDB'),
             size = 4) +
  scale_x_log10(breaks = scales::trans_breaks("log10", function(x) 10^x),
                labels = scales::trans_format("log10", scales::math_format(10^.x))) +
  scale_color_viridis_d(name = '') +
  labs(y = NULL,
       x = 'Log concentration (ug/L)',
       title = paste0(tax, ' EC50 values'),
       subtitle = '20 most tested chemicals') +
  theme(legend.position = 'bottom')

# save --------------------------------------------------------------------
ggsave(gg, filename = file.path(article, 'figures', 'daphnia_ec50_standartox_ppdb_comparison.png'),
       width = 10, height = 8)
saveRDS(gg, file.path(cachedir, 'daphnia_ec50_standartox_ppdb_comparison.rds'))



