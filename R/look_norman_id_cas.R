# script to match CAS with NORMAN ID

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
fl = file.path(normandir, 'data', 'report_matched.xlsx')
dat = read_excel(fl)
setDT(dat)
setnames(dat,
         c('chemical_name', 'MATCH_NormanID'),
         c('name', 'normanid'))
dat = dat[ , .SD, .SDcols = c('name', 'cas_fixed', 'normanid') ]
# TODO new data from Peter (doesn't work)
# fl = file.path(normandir, 'data', 'susdat_id_cas.xlsx')
# dat = read_excel(fl)
# setDT(dat)
# setnames(dat, c('name', 'cas_rn', 'cas', 'casnr', 'susdat_id'))

# preparation -------------------------------------------------------------
dat[ , cas := gsub('CAS_RN:\\s', '', cas_fixed) ]
dat[ , casnr := as.integer(casconv(cas, direction = 'tocasnr')) ]
setcolorder(dat, 'casnr')

# chck --------------------------------------------------------------------
chck_dupl(dat, 'casnr')

# write -------------------------------------------------------------------
write_tbl(dat, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'lookup', tbl = 'norman_id_cas',
          key = 'casnr',
          comment = 'NORMAN ID lookup table')

# log ---------------------------------------------------------------------
log_msg('LOOKUP: NORMAN: SusdatID + CAS script.')

# cleaning ----------------------------------------------------------------
clean_workspace()





