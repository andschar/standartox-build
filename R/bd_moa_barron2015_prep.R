# script to read Mode of Action (MOA) data from Barront et al. 2015
# TODO split into download and preparation script
# TODO find download link for spreadsheet data

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
moa = read_excel(file.path(data, 'moa', 'es7b02337_si_002.xlsx'))
setDT(moa)
clean_names(moa)

# prepare -----------------------------------------------------------------
# Moatox broad (after Barron et al. 2015)
moa_broad = dcast(moa, cas ~ moatox_broad,
                  value.var = 'moatox_broad', fun.aggregate = length)
moa_broad = moa_broad[ -grep('\\*', cas) ]
moa_broad = moa_broad[ , .SD, .SDcols =! 'NA' ]
setnames(moa_broad,
         names(moa_broad),
         c('cas', 'ache', 'electrontransp', 'ioc', 'narcosis', 'neurotoxicity', 'reactivity'))

# Maotox specific (after Barron et al. 2015)
moa_spec = dcast(moa, cas ~ moatox_specific,
                 value.var = 'moatox_specific', fun.aggregate = length)
moa_spec = moa_spec[ -grep('\\*', cas) ]
moa_spec = moa_spec[ , .SD, .SDcols =! 'NA' ]
setnames(moa_spec, gsub('/', ' ', names(moa_spec)))
clean_names(moa_spec)

# chck --------------------------------------------------------------------
chck_dupl(moa_broad, 'cas')
chck_dupl(moa_spec, 'cas')

# write -------------------------------------------------------------------
write_tbl(moa_broad, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'moa', tbl = 'barron_broad',
          key = 'cas',
          comment = 'Mode of Action (MoA) data from Barron et al. 2015')

# log ---------------------------------------------------------------------
log_msg('MOA: Barron et al. 2015 script run')

# cleaning ----------------------------------------------------------------
clean_workspace()





