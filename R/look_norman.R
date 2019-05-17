# create lookup tables

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# retrieve values ---------------------------------------------------------
drv = dbDriver("PostgreSQL")
con = dbConnect(drv, user = DBuser, dbname = DBetox, host = DBhost, port = DBport, password = DBpassword)

chemical_analysis = data.table(dbGetQuery(con,
  "SELECT * FROM ecotox.chemical_analysis_codes"
))

effect_codes = data.table(dbGetQuery(con,
  "SELECT effect_codes.*, COUNT(effect) n
   FROM ecotox.results
   RIGHT OUTER JOIN ecotox.effect_codes ON results.effect = effect_codes.code
   GROUP BY code
   ORDER BY n DESC"
))

endpoint = data.table(dbGetQuery(con,
  "SELECT endpoint_codes.*, COUNT(endpoint) n
   FROM ecotox.results
   RIGHT OUTER JOIN ecotox.endpoint_codes ON results.endpoint = endpoint_codes.code
   GROUP BY code, description
   ORDER BY n DESC"
))

media_type = data.table(dbGetQuery(con,
  "SELECT media_type_codes.*, COUNT(media_type) n
   FROM ecotox.tests
   RIGHT OUTER JOIN ecotox.media_type_codes ON media_type = code
   GROUP BY media_type, code
   ORDER BY n DESC"
))

test_location = data.table(dbGetQuery(con,
  "SELECT *
   FROM ecotox.test_location_codes"
))

test_type = data.table(dbGetQuery(con,
  "SELECT test_type, COUNT(test_type) n
   FROM ecotox.tests
   GROUP BY test_type
   ORDER BY n DESC"))

dbDisconnect(con)
dbUnloadDriver(drv)

# build lookup tables -----------------------------------------------------
# chemical analysis codes (e.g. C - Calculated, M - Measured)
nr = c('--', 'NC', 'NR')
est = c('C')
chemical_analysis[ code %in% nr, description_norman := 'not reported' ]
chemical_analysis[ code %like% '^C', description_norman := 'estimated' ]
chemical_analysis[ code %like% '^U', description_norman := 'nominal' ]
chemical_analysis[ code %like% '^X', description_norman := 'nominal but measured' ]
chemical_analysis[ code %like% '^M', description_norman := 'measured (not specified)' ]
chemical_analysis[ code %like% '^M', description_norman := 'chemical analysis reported' ]

# ecotox group
# TODO CHECK with existing classification
# effect codes
rem = c('ACC', 'BCM', 'CEL', 'PHY', 'AEG', 'AVO', 'FDB', 'GEN', 'HRM', 'ENZ', 'IMM', 'INJ', 'PRS', 'NR', '--')
effect_codes[ , description_norman := tolower(description) ]
effect_codes[ code %like% paste0(rem, collapse = '|'), description_norman := 'remove' ]
# endpoints
rem = c('--', 'NR', 'T1/2', 'MAT', 'LT', 'BCF', 'BAF', 'BMC', 'BMD')
endpoint[ , code_norman := code ]
endpoint[ code %like% paste0(rem, collapse = '|'), code_norman := 'remove' ]
# media type
rem = c('AGR', 'CUL', 'FAB', 'FLT', 'HUM', 'LIT', 'POP', 'SLG', 'UKN', 'NC')
soil = c('ART', 'MIN', 'NAT', 'UKS')
other = c('AQU', 'HYP', 'MAN', 'MIX', 'NONE')
nr = c('NR', '--')
media_type[ code %in% rem, description_norman := 'remove' ]
media_type[ code %in% soil, description_norman := 'soil' ]
media_type[ code %in% other, description_norman := 'other' ]
media_type[ code %in% nr, description_norman := 'not reported' ]
media_type[ code == 'FW', description_norman := 'freshwater' ]
media_type[ code == 'SW', description_norman := 'saltwater' ]
media_type[ code == 'SED', description_norman := 'sediment' ]
use = c('AQU', 'ART', 'CUL', 'FW', 'HYP', 'MIN', 'NAT', 'NC', 'NONE', 'NR', 'SW', 'UKN', 'UKS') # for what?
media_type[ code %in% use, use := 'x' ]
# test location
test_location[ code == 'FIELDA', description_norman := 'field experiment' ]
test_location[ code == 'FIELDN', description_norman := 'field study result' ]
test_location[ code == 'FIELDU', description_norman := 'field study result' ]
test_location[ code == 'LAB', description_norman := 'experimental result' ]
test_location[ code == 'NR', description_norman := 'not reported' ]
# test type
test_type[ test_type %in% c('NR', 'NC', '', ' ',  '--'),
           description_norman := 'not reported' ]
test_type[ test_type == 'SBACUTE', description_norman := 'sub-acute' ]
test_type[ test_type == 'SBCHRON', description_norman := 'sub-chronic' ]
test_type[ test_type %in% c('ACUTE', 'ACTELS'),
           description_norman := 'acute' ]
test_type[ test_type %in% c('CHRONIC', 'CHRELS', 'ELS', 'FLC', 'GEN', 'PLC'),
           description_norman := 'chronic' ]
setnames(test_type, 'test_type', 'code')

# list --------------------------------------------------------------------
lookup_l = list(chemical_analysis = chemical_analysis,
                effect_codes = effect_codes,
                endpoint = endpoint,
                media_type = media_type,
                test_location = test_location,
                test_type = test_type)

# check -------------------------------------------------------------------
sapply(lookup_l, chck_dupl, col = 'code')

# write lookup tables -----------------------------------------------------
for (i in seq_along(lookup_l)) {
  
  schema = 'ecotox'
  tbl = lookup_l[[i]]
  name = names(lookup_l[i])
  name = paste0(name, '_lookup')
  message('Writing: ', name)
  ## to postgres
  write_tbl(tbl, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
            dbname = DBetox, schema = schema, tbl = name,
            key = 'code',
            comment = paste0(name, ' ', 'lookup table'))
  
}

# log ---------------------------------------------------------------------
log_msg('LOOK: Duration lookup tables script run.')

# cleaning ----------------------------------------------------------------
clean_workspace()








