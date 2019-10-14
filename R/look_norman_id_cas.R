# script to match CAS with NORMAN ID

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
fl = file.path(normandir, 'data', 'report_matched.xlsx')
dat = read_excel(fl)
setDT(dat)

# preparation -------------------------------------------------------------
dat[ , cas_fixed2 := gsub('CAS_RN:\\s', '', cas_fixed) ]
cols = c('cas', 'cas_fixed2', 'MATCH_NormanID')
dat2 = dat[ , .SD, .SDcols = cols ]
dat2[ , casnr := as.integer(gsub('-', '', cas)) ]
dat2[ , casnr_fixed2 := as.integer(gsub('-', '', cas_fixed2)) ]
setnames(dat2, 'MATCH_NormanID', 'normanid')
setnames(dat2, tolower(names(dat2)))
setcolorder(dat2, 'casnr')

# chck --------------------------------------------------------------------
chck_dupl(dat2, 'cas')

# write -------------------------------------------------------------------
write_tbl(dat2, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'lookup', tbl = 'norman_id_cas',
          key = 'cas',
          comment = 'NORMAN ID lookup table')

# log ---------------------------------------------------------------------
log_msg('NORMAN IDs + fixed CAS script run')

# cleaning ----------------------------------------------------------------
clean_workspace()





