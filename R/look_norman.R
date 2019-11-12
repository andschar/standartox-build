# create NORMAN lookup tables

# setup -------------------------------------------------------------------
source('R/gn_setup.R')

# retrieve values ---------------------------------------------------------
drv = dbDriver("PostgreSQL")
con = dbConnect(drv, user = DBuser, dbname = DBetox, host = DBhost, port = DBport, password = DBpassword)
chemical_analysis = data.table(dbGetQuery(con,
                                          "SELECT codes.*, COUNT(chem_analysis_method) n
   FROM ecotox.results
   RIGHT OUTER JOIN ecotox.chemical_analysis_codes codes ON results.chem_analysis_method = codes.code
   GROUP BY code, description
   ORDER BY n DESC"
))
chemical_analysis = data.table(dbGetQuery(con,
  "SELECT chem_analysis_method AS code, COUNT(*) n
   FROM ecotox.results
   LEFT JOIN ecotox.chemical_analysis_codes codes ON results.chem_analysis_method = codes.code
   GROUP BY chem_analysis_method, description
   ORDER BY n DESC"
))
effect = data.table(dbGetQuery(con,
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
  "SELECT media_type AS code, description, COUNT(*) n
   FROM ecotox.tests tests
   LEFT JOIN ecotox.media_type_codes codes ON tests.media_type = codes.code
   GROUP BY media_type, description
   ORDER BY n DESC"
))
test_location = data.table(dbGetQuery(con,
  "SELECT codes.*, COUNT(test_location) n
   FROM ecotox.tests
   RIGHT OUTER JOIN ecotox.test_location_codes codes ON tests.test_location = codes.code
   GROUP BY test_location, code
   ORDER BY n DESC"
))
test_type = data.table(dbGetQuery(con,
  "SELECT codes.*, COUNT(test_type) n
   FROM ecotox.tests
   RIGHT OUTER JOIN ecotox.test_type_codes codes ON tests.test_type = codes.code
   GROUP BY test_type, code
   ORDER BY n DESC"))

dbDisconnect(con)
dbUnloadDriver(drv)

# build lookup tables -----------------------------------------------------
# chemical analysis codes (e.g. C - Calculated, M - Measured)
chemical_analysis[ code %in% c('--', 'NC', 'NR', ''), description_norman := 'n.r.' ]
chemical_analysis[ code %like% '^C', description_norman := 'estimated' ]
chemical_analysis[ code %like% '^U', description_norman := 'nominal' ]
chemical_analysis[ code %like% '^X', description_norman := 'nominal but measured' ]
chemical_analysis[ code %like% '^M', description_norman := 'measured (not specified)' ]
chemical_analysis[ code %like% '^Z', description_norman := 'chemical analysis reported' ]

# ecotox group
## effect codes
rem = c('ACC', 'BCM', 'CEL', 'PHY', 'AEG', 'AVO', 'FDB', 'GEN', 'HRM', 'ENZ', 'IMM', 'INJ', 'PRS', 'NR', '--')
effect[ , description_norman := tolower(description) ]
effect[ code %like% paste0(rem, collapse = '|'), remove := 1L ]
# endpoints
rem = c('--', 'NR', 'T1/2', 'MAT', 'LT', 'BCF', 'BAF', 'BMC', 'BMD')
endpoint[ , code_norman := code ]
endpoint[ code %like% paste0(rem, collapse = '|'), code_norman := 'remove' ]
## media type
media_type[ grep('FW|NONE', code), description_norman := 'freshwater' ]
media_type[ grep('SW', code), description_norman := 'saltwater' ]
media_type[ grep('NONE', code), description_norman := 'no substrate' ]
media_type[ grep('NAT|ART', code), description_norman := 'soil' ]
media_type[ grep('AQU|HYP', code), description_norman := 'aqueous hydroponic' ]
media_type[ grep('NAT|ART|UKS|MIN', code), description_norman := 'soil' ]
media_type[ grep('FLT', code), description_norman := 'filter paper' ]
media_type[ grep('AGR', code), description_norman := 'agar' ]
media_type[ grep('LIT', code), description_norman := 'litter' ]
media_type[ grep('FAB', code), description_norman := 'fabric' ]
media_type[ grep('MAN', code), description_norman := 'manure' ]
media_type[ grep('POP', code), description_norman := 'plaster of paris' ]
media_type[ grep('HUM', code), description_norman := 'humus' ]
media_type[ grep('MIX', code), description_norman := 'media mixture' ]
media_type[ grep('SED', code), description_norman := 'sediment' ]
media_type[ grep('SLG', code), description_norman := 'sludge' ]
media_type[ grep('CUL', code), description_norman := 'culture' ]
media_type[ grep('NONE', code), description_norman := 'no substrate' ]
media_type[ grep('NR|NC|--|UKN', code), description_norman := 'freshwater' ] # formerly 'n.r.'
## test location
rem = NA
test_location[ code == 'FIELDA', description_norman := 'field experiment' ]
test_location[ code == 'FIELDN', description_norman := 'field study result' ]
test_location[ code == 'FIELDU', description_norman := 'field study result' ]
test_location[ code == 'LAB', description_norman := 'experimental result' ]
test_location[ code %in% c('NR', '--'), description_norman := 'n.r.' ]
test_location[ code %in% rem, remove := 1L ]
## test type
rem = NA
test_type[ code %in% c('NR', 'NC', '', ' ',  '--'),
           description_norman := 'n.r.' ]
test_type[ code == 'SBACUTE', description_norman := 'sub-acute' ]
test_type[ code == 'SBCHRON', description_norman := 'sub-chronic' ]
test_type[ code %in% c('ACUTE', 'ACTELS'),
           description_norman := 'acute' ]
test_type[ code %in% c('CHRONIC', 'CHRELS', 'ELS', 'FLC', 'GEN', 'PLC'),
           description_norman := 'chronic' ]
test_type[ code %in% rem, remove := 1L ]

# list --------------------------------------------------------------------
lookup_l = list(chemical_analysis = chemical_analysis,
                effect = effect,
                endpoint = endpoint,
                media_type = media_type,
                test_location = test_location,
                test_type = test_type)

# check -------------------------------------------------------------------
sapply(lookup_l, chck_dupl, col = 'code')

# write lookup tables -----------------------------------------------------
for (i in seq_along(lookup_l)) {
  
  schema = 'lookup'
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
log_msg('LOOKUP: NORMAN: lookup tables script run.')

# cleaning ----------------------------------------------------------------
clean_workspace()








