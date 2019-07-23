# useage, acute-chronic and standard-test classification for NORMAN
# data provided by Peter v. d. Ohe

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
dat = fread(file.path(normandir, 'data', 'lookup_acute_chronic_standard.csv'), na.strings = '')

# chck --------------------------------------------------------------------
chck_dupl(dat, 'result_id')

# write -------------------------------------------------------------------
write_tbl(dat, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'ecotox', tbl = 'lookup_acute_chronic_standard',
          key = 'result_id',
          comment = 'NORMAN use, acute-chronic and standard-test lookup table')

# log ---------------------------------------------------------------------
log_msg('LOOK: NORMAN use, acute-chronic and standard-test tables script run.')

# cleaning ----------------------------------------------------------------
clean_workspace()


