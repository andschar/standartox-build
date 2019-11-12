# script to match CAS with NORMAN ID

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
fl = file.path(normandir, 'data', 'report_matched.xlsx')
dat_old = read_excel(fl)
setDT(dat_old)
fl = file.path(normandir, 'data', 'susdat_id_cas.xlsx')
dat = read_excel(fl)
setDT(dat)
setnames(dat, c('name', 'cas_rn', 'cas', 'casnr', 'susdat_id'))

# preparation -------------------------------------------------------------
# dat[ , cas_fixed2 := gsub('CAS_RN:\\s', '', cas_fixed) ]
cols = c('name', 'cas', 'casnr', 'susdat_id')
dat2 = dat[ , .SD, .SDcols = cols ]
dat2[ , casnr := as.integer(gsub('-', '', casnr)) ]
setcolorder(dat2, 'casnr')

# chck --------------------------------------------------------------------
chck_dupl(dat2, 'cas')

dat2[ , .N, cas][ order(-N)]

# write -------------------------------------------------------------------
write_tbl(dat2, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'lookup', tbl = 'norman_id_cas',
          key = 'cas',
          comment = 'NORMAN ID lookup table')

# log ---------------------------------------------------------------------
log_msg('LOOKUP: NORMAN: SusdatID + CAS script.')

# cleaning ----------------------------------------------------------------
clean_workspace()





