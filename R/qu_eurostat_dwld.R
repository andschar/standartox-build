# sctipt to query the annex files from the meta data on pesticide sales in Europe
# NOTE downloaded and prepared manually since the file structure is very bad
# NOTE 'https://ec.europa.eu/eurostat/cache/metadata/Annexes/aei_fm_salpest09_esms_an1.xlsx'
# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
dt = fread(file.path(data, 'eurostat', 'eurostat_20200210.csv'),
           na.strings = '')

# write -------------------------------------------------------------------
saveRDS(dt, file.path(cachedir, 'eurostat', 'eurostat_annexes.rds'))

# log ---------------------------------------------------------------------
log_msg('QUERY: Eurostat: download script run.')

# cleaning ----------------------------------------------------------------
clean_workspace()
