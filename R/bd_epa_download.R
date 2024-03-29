# this is a script that builds the EPA ECOTOX data base locally
# it follows roughly this guide: https://edild.github.io/localecotox/

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# download ----------------------------------------------------------------
baseurl = 'ftp://newftp.epa.gov/ECOTOX/' # removing the trailing '/' causes an error
ftp = html_text(read_html(baseurl))
date_pattern = '[0-9]{2}_[0-9]{2}_[0-9]{4}'

# data.table of ftp files (+ date column)
file = unlist(regmatches(ftp, gregexpr(sprintf('ecotox_ascii_%s.exe', date_pattern), ftp)))
date = as.Date(unlist(regmatches(file, gregexpr(date_pattern, file))), format = '%m_%d_%Y')

ascii_dt = data.table(file = file, date = date)
setorder(ascii_dt, -date)

file_fin = ascii_dt$file[1]
file_url = paste0(baseurl, file_fin)
output = file.path(data_ecotox, file_fin)

# download file + unzip ---------------------------------------------------
if (!basename(output) %in% list.files(data_ecotox)) {
  
  system(sprintf('wget -P %s %s', data_ecotox, file_url)) # quite slow
  system(sprintf('unzip %s -d %s', output, data_ecotox))
} else {
  log_msg('ECOTOX: up to date - no new build needed.')
}

# setup ECOTOX variables --------------------------------------------------
etoxdirs = grep('ecotox', list.dirs(data_ecotox, recursive = FALSE), value = TRUE)
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
saveRDS(etoxdir, file.path(cachedir, 'etox_data_path.rds'))

# check -------------------------------------------------------------------
if (length(releases) == 0) {
  log_msg('Newest etox file (DBetox) file can not be found.')
}

# log ---------------------------------------------------------------------
log_msg('ECOTOX: download run.')

# cleaning ----------------------------------------------------------------
clean_workspace()



