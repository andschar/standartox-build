# sctipt to query the annex files from the meta data on pesticide sales in Europe
# why? because they contain information on the classification of chemicals

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

url = 'https://ec.europa.eu/eurostat/cache/metadata/Annexes/aei_fm_salpest09_esms_an5.xls'
file = tempfile()

# data --------------------------------------------------------------------
download.file(url = url, destfile = file)
dt = as.data.table(read_excel(file, skip = 1))
setnames(dt, c('code', 'cname', 'cas', 'cipac'))

saveRDS(dt, file.path(cachedir, 'eurostat_annexes.rds'))

# log ---------------------------------------------------------------------
log_msg('Eurostat download script run')

# cleaning ----------------------------------------------------------------
clean_workspace()





