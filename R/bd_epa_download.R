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
etoxdir = grep('ecotox', list.dirs(datadir, recursive = FALSE), value = TRUE)
release = regmatches(etoxdir, regexpr('[0-9]{2}_[0-9]{2}_[0-9]{4}', etoxdir))
release = as.character(max(as.Date(release, format = '%m_%d_%Y')))
DBetox = paste0('etox', gsub('-', '', release))
saveRDS(DBetox, file.path(cachedir, 'data_base_name_version.rds'))

if (is.na(release)) {
  msg = 'Newest etox file (DBetox) file can not be found.'
  log_msg(msg); rm(msg)
}

# cleaning ----------------------------------------------------------------
rm(baseurl, ftp, date_pattern,
   file, date, ascii_dt, file_fin, file_url, output,
   release)



