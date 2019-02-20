# this is a script that builds the EPA ECOTOX data base locally
# it follows roughly this guide: https://edild.github.io/localecotox/

# download ----------------------------------------------------------------
baseurl = 'ftp://newftp.epa.gov/ECOTOX/' # removing the trailing '/' causes an error
ftp = getURL(baseurl)
date_pattern = '[0-9]{2}_[0-9]{2}_[0-9]{4}'

# data.table of ftp files (+ date column)
file = unlist(regmatches(ftp, gregexpr(sprintf('ecotox_ascii_%s.exe', date_pattern), ftp)))
date = as.Date(unlist(regmatches(file, gregexpr(date_pattern, file))), format = '%m_%d_%Y')

ascii_dt = data.table(file = file, date = date)
setorder(ascii_dt, -date)

file_fin = ascii_dt$file[1]
file_url = paste0(baseurl, file_fin)
output = file.path(datadir, file_fin)

# download file + unzip ---------------------------------------------------
if (!basename(output) %in% list.files(datadir)) {
  
  system(sprintf('wget -P %s %s', datadir, file_url)) # quite slow
  system(sprintf('unzip %s -d %s', output, datadir))
} else {
  
  msg = 'ECOTOX up to date - no new build needed.'
  log_msg(msg); rm(msg)
}

# setup ECOTOX variables --------------------------------------------------
etoxdirs = grep('ecotox', list.dirs(datadir, recursive = FALSE), value = TRUE)
releases = regmatches(etoxdirs, regexpr(date_pattern, etoxdirs))

etoxdir_lookup = data.table(
  path = etoxdirs,
  release = as.Date(releases, format = '%m_%d_%Y')
)
setorder(etoxdir_lookup, -release)

## ECOTOX database
DBetox = paste0('etox', gsub('-', '', etoxdir_lookup$release[1]))
etoxdir = etoxdir_lookup$path[1]

# writing -----------------------------------------------------------------
# ECOTOX version
saveRDS(DBetox, file.path(cachedir, 'data_base_name_version.rds'))
saveRDS(DBetox, file.path(shinydata, 'data_base_name_version.rds'))

# check -------------------------------------------------------------------
if (length(releases) == 0) {
  msg = 'Newest etox file (DBetox) file can not be found.'
  log_msg(msg); rm(msg)
}

# cleaning ----------------------------------------------------------------
rm(list = grep('chck', ls(), value = TRUE))



