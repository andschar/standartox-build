# script to prepare and clean EPA ECOTOX data

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))
dbname = readRDS(file.path(cachedir, 'data_base_name_version.rds'))
etox_version = gsub('[^0-9]+', '', dbname)
etox_path = readRDS(file.path(cachedir, 'etox_data_path.rds'))

# meta files --------------------------------------------------------------
# code appendix
download.file('https://cfpub.epa.gov/ecotox/pdf/codeappendix.pdf',
              file.path(data, 'ecotox', paste0('codeappendix', etox_version, '.pdf')))
# user guide
download.file('https://nepis.epa.gov/Exe/ZyPDF.cgi?Dockey=P100UUBD.txt',
              file.path(data, 'ecotox', paste0('user_guide', etox_version, '.pdf')))

# meta schema -------------------------------------------------------------
# TODO check if still needed
info = data.table(
  dbname = dbname,
  etox_version = etox_version,
  etox_path = etox_path
)
# write
write_tbl(info,
          dbname = DBetox, schema = 'meta', tbl = 'info',
          host = DBhost, port = DBport, user = DBuser, password = DBpassword,
          comment = 'Meta information table on data base build.')

# log ---------------------------------------------------------------------
log_msg('ECOTOX: META: files have been downloaded')

# cleaning ----------------------------------------------------------------
clean_workspace()