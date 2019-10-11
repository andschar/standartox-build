# useage, acute-chronic and standard-test classification for NORMAN
# data provided by Peter v. d. Ohe

# setup -------------------------------------------------------------------
source('R/gn_setup.R')

# lookup ------------------------------------------------------------------
dat = fread(file.path(normandir, 'lookup', 'lookup_use_acute_chronic_standard.csv'), na.strings = '')

# data --------------------------------------------------------------------
drv = dbDriver("PostgreSQL")
con = dbConnect(drv, user = DBuser, dbname = DBetox, host = DBhost, port = DBport, password = DBpassword)

q = "SELECT results.result_id,
            coalesce(species.latin_name, 'NA') || '_' ||
            coalesce(clean(results.endpoint), 'NA') || '_' || 
            coalesce(clean(results.effect), 'NA') || '_' ||
            coalesce(clean(results.measurement), 'NA') || '_' ||
            coalesce(clean(results.obs_duration_mean) || clean(results.obs_duration_unit), 'NAh') AS id
     FROM ecotox.tests
     LEFT JOIN ecotox.results ON tests.test_id = results.test_id
     LEFT JOIN ecotox.species ON tests.species_number = species.species_number"

ids = dbGetQuery(con, q)
setDT(ids)

dbDisconnect(con)
dbUnloadDriver(drv)

# merge -------------------------------------------------------------------
fin = merge(ids, dat, by = 'id', all.x = TRUE)
fin = fin[ ,.SD, .SDcols = c('result_id', 'nor_use', 'nor_acute_chronic', 'nor_standard_test') ]

# chck --------------------------------------------------------------------
chck_dupl(fin, 'result_id')

# write -------------------------------------------------------------------
write_tbl(fin, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'lookup', tbl = 'lookup_norman_use_acute_chronic_standard',
          key = 'result_id',
          comment = 'NORMAN use, acute-chronic and standard-test lookup table')

# log ---------------------------------------------------------------------
log_msg('LOOK: NORMAN use, acute-chronic and standard-test tables script run.')

# cleaning ----------------------------------------------------------------
clean_workspace()
