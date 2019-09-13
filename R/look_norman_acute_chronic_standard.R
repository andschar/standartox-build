# useage, acute-chronic and standard-test classification for NORMAN
# data provided by Peter v. d. Ohe

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
dat = fread(file.path(normandir, 'data', 'lookup_acute_chronic_standard.csv'), na.strings = '')

# additions ---------------------------------------------------------------
# (1) make 'biomass', 'chlorophyll a concentration', 'abundance' to chronic
time = Sys.time()
drv = dbDriver("PostgreSQL")
con = dbConnect(drv, user = DBuser, dbname = DBetox, host = DBhost, port = DBport, password = DBpassword)

q = "SELECT results.result_id,
            clean(results.obs_duration_mean) obs_duration_mean,
            clean(results.obs_duration_mean)::numeric * duration_unit_lookup.multiplier obs_duration_mean2,
            clean(results.obs_duration_unit) obs_duration_unit,
            duration_unit_lookup.unit_conv obs_duration_unit2,
            clean(results.endpoint) endpoint,
            clean(results.effect) effect,
            clean(results.measurement) measurement,
            species.latin_name,
            species.family,
            ac_cr.*
     FROM ecotox.tests
     LEFT JOIN ecotox.results ON tests.test_id = results.test_id
     LEFT JOIN ecotox.refs ON tests.reference_number = refs.reference_number
     LEFT JOIN ecotox.chemicals ON tests.test_cas = chemicals.cas_number
     LEFT JOIN ecotox.species ON tests.species_number = species.species_number
     LEFT JOIN ecotox.duration_unit_lookup ON results.obs_duration_unit = duration_unit_lookup.obs_duration_unit
     LEFT JOIN lookup.lookup_acute_chronic_standard ac_cr ON results.result_id = ac_cr.result_id"

add = dbGetQuery(con, q)
setDT(add)

dbDisconnect(con)
dbUnloadDriver(drv)
Sys.time() - time

fam_ok = add[ norman_use == 'yes',
              sort(unique(family)) ]
idx_chronic = add[ family %in% fam_ok &
                     measurement %in% c('ABND', 'CHLA', 'BMAS'), result_id ]
idx_acute = add[ family %in% fam_ok &
                   measurement == 'PGRT', result_id ]
dat[ result_id %in% idx_chronic, `:=`
     (norman_use = 'yes',
       acute_chronic = 'chronic',
       standard_test = 'no') ]
dat[ result_id %in% idx_acute, `:=`
     (norman_use = 'yes',
       acute_chronic = 'chronic',
       standard_test = 'no') ]

# chck --------------------------------------------------------------------
chck_dupl(dat, 'result_id')

# write -------------------------------------------------------------------
write_tbl(dat, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'lookup', tbl = 'lookup_acute_chronic_standard',
          key = 'result_id',
          comment = 'NORMAN use, acute-chronic and standard-test lookup table')

# log ---------------------------------------------------------------------
log_msg('LOOK: NORMAN use, acute-chronic and standard-test tables script run.')

# cleaning ----------------------------------------------------------------
clean_workspace()


