# script to prepare and clean EPA ECOTOX data

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# meta data ---------------------------------------------------------------
# code appendix
download.file('https://cfpub.epa.gov/ecotox/pdf/codeappendix.pdf',
              file.path(data, 'ecotox', 'codeappendix.pdf'))
# user guide
download.file('https://nepis.epa.gov/Exe/ZyPDF.cgi?Dockey=P100UUBD.txt',
              file.path(data, 'ecotox', 'user_guide.pdf'))

# meta schema -------------------------------------------------------------
dbname = readRDS(file.path(cachedir, 'data_base_name_version.rds'))
etox_version = gsub('[^0-9]+', '', dbname)
etox_path = readRDS(file.path(cachedir, 'etox_data_path.rds'))

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