# script to assign exposure type entries (e.g. S - Static (water), GV - Gavage, etc.)

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data base
DBetox = readRDS(file.path(cachedir, 'data_base_name_version.rds'))

# (1) query ---------------------------------------------------------------
if (online_db) {
  drv = dbDriver("PostgreSQL")
  con = dbConnect(drv, user = DBuser, dbname = DBetox, host = DBhost, port = DBport, password = DBpassword)
  
  exp_typ = dbGetQuery(con, "SELECT *
                             FROM ecotox.exposure_type_codes")
  setDT(exp_typ)
    
  dbDisconnect(con)
  dbUnloadDriver(drv)
  
  saveRDS(exp_typ, file.path(cachedir, 'source_epa_exposure_type.rds'))
  
} else {
  
  exp_typ = readRDS(file.path(cachedir, 'source_epa_exposure_type.rds'))
}


# abbreviations -----------------------------------------------------------

## Diet (D) exposure codes ----
diet = c('CH', 'DR', 'DT', 'FD', 'GE', 'GV', 'IG', 'LC', 'OR')
# FD - chemical incorporated in the Food, GV - Gavage (oral intubation)

## Injection (I) codes ----
inj = c('IA', 'IAC', 'IB', 'IC', 'ICL', 'ID', 'IE', 'IF', 'IH', 'II', 'IJ', 'IK', 'ILP', 'IM', 'IO', 'IP', 'IQ', 'IS', 'IU', 'IV', 'IY', 'IZ', 'OP', 'SC', 'SD', 'YK')

## Multiple (M) Application codes ----
multi = 'MU'
# MU - Multiple routes between application codes (e.g. dermal and injection)

## Aquatic Lab exposure types ----
aqu_lab = c('S', 'R', 'F', 'P', 'L', 'AQUA - NR')
# S - Static, R - Renewal, F - Flow through, AQUA-NR - Aquatic - not reported

## Aquatic Field Exposure types ----
aqu_field = c('B', 'E', 'O')
# B - Tidal, E - Lentic, O - Lotic

## Topical (T) Application codes ----
topical = c('DM', 'FC', 'MM', 'OC', 'PC', 'SA', 'SH', 'TP')
# DM - Dermal

## Environmental (V) exposure codes ----
enviro = c('AE', 'AG', 'AS', 'CM', 'DA', 'DU', 'DW', 'EN', 'FS', 'FU', 'GG', 'GM', 'GS', 'HP', 'HS', 'IN', 'MI', 'MT', 'PR', 'PT', 'PU', 'SO', 'SP', 'SS', 'TER-NR', 'WA')
# EN - Environmental, unspecified, SP - Spray, DA - Direct Application

## In-vitro exposure codes ----
vitro = 'ivt'

# preparation -------------------------------------------------------------
exp_typ[ code %in% diet, exp_route := 'diet' ]
exp_typ[ code %in% inj, exp_route := 'inj' ]
exp_typ[ code %in% multi, exp_route := 'multi' ]
exp_typ[ code %in% aqu_lab, exp_route := 'aqu_lab' ]
exp_typ[ code %in% aqu_field, exp_route := 'aqu_field' ]
exp_typ[ code %in% topical, exp_route := 'topical' ]
exp_typ[ code %in% enviro, exp_route := 'enviro' ]
exp_typ[ code %in% vitro, exp_route := 'vitro' ]

# names -------------------------------------------------------------------
setnames(exp_typ,
         c('code', 'description'),
         c('exposure_type', 'exp_regime'))


