# script to retrieve single doses used in the test

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# data base
DBetox = readRDS(file.path(cachedir, 'data_base_name_version.rds'))

# query -------------------------------------------------------------------
if (online_db) {
  drv = dbDriver("PostgreSQL")
  con = dbConnect(drv, user = DBuser, dbname = DBetox, host = DBhost, port = DBport, password = DBpassword)
  
  dose = dbGetQuery(con, "SELECT *
                          FROM ecotox.doses")
  dose_responses = dbGetQuery(con, "SELECT *
                                    FROM ecotox.dose_responses
                                    LEFT JOIN ecotox.effect_codes ON dose_responses.effect_code = effect_codes.code")
  dose_response_details = dbGetQuery(con, "SELECT *
                                           FROM ecotox.dose_response_details")
  setDT(dose)
  setDT(dose_responses)
  setDT(dose_response_details)
  
  dbDisconnect(con)
  dbUnloadDriver(drv)
  
  saveRDS(dose, file.path(cachedir, 'dose.rds'))
  saveRDS(dose_responses, file.path(cachedir, 'dose_responses.rds'))
  saveRDS(dose_response_details, file.path(cachedir, 'dose_response_details.rds'))
  
} else {
  
  dose = readRDS(file.path(cachedir, 'dose.rds'))
  dose_responses = readRDS(file.path(cachedir, 'dose_responses.rds'))
  dose_response_details = readRDS(file.path(cachedir, 'dose_response_details.rds'))
}

# preparation -------------------------------------------------------------
# remove duplicated entries
dose = dose[ !duplicated(dose, by = c('test_id', 'dose_number')) ]
# dcast
dose_dc = dcast(dose, test_id ~ dose_number,
                value.var = 'dose1_mean')
setnames(dose_dc, paste0('dose', names(dose_dc)))
setnames(dose_dc, 'dosetest_id', 'test_id')

# calculation -------------------------------------------------------------

## Vehicle control (yes/no)
# CONTINUE HERE!!!
# WTF is going on here????
# Why is the filter not wirking?
vc = unique(dose[ control_type %in% c('V', '', 'NR') ]$test_id)
dose[test_id %in% vc, .N, control_type]
vc = unique(dose[ grep('(?i)V', control_type) ]$test_id)
dose_dc[ test_id %in% vc, control_vc := 'yes' ]
### END WTF


## dd (80)
dd =
  dose[ ! dose1_mean %in% c('NR', 'NC', '', ' ',  '--'),
        .(do = paste0(dose1_mean, ' ', dose_conc_unit, collapse = ' '),
          co_ty = trimws(paste0(control_type, collapse = ' '))),
        test_id ][order(test_id)]
dd[ co_ty %like% 'V', vc := 'yes' ]
dd[ co_ty %like% 'NR', vc := 'not reported' ]
dd[ co_ty %like% 'NC', vc := 'not reported' ]
dd[ is.na(vc), vc := 'no' ]


# control mortality -------------------------------------------------------
# control types:
# C - Concurrent control - controls are run simultaneously with the exposure
# V - Carrier or solvent - Organisms are exposed to carrier or solvent as the only control
# P - Positive controls - an exposure that causes a desired effect in the experiment, and document that the test and equipment are working, were used
# p. 34 codeappendix

dose2 = merge(dose, dose_response_details, by = 'dose_id', all.x = TRUE)
dose2 = merge(dose2, dose_responses[ , .SD, .SDcols =! 'test_id' ],
              by = 'dose_resp_id', all.x = TRUE)
ctrl_mort_cols = c('test_id', 'dose_id', 'dose_resp_id', 'control_type', 'effect_code', 'response_mean', 'response_unit')

## Control Mortality
dose3 = dose2[ , .SD, .SDcols = ctrl_mort_cols ]

cm =
  dose3[ control_type == 'C' &
           effect_code == 'MOR' &
           response_unit == '%',
         .(control_neg_mortality = paste(effect_code,
                                         max(gsub('\\+', '', response_mean)),
                                         response_unit,
                                         sep = ' ')),
         .(test_id, response_unit, effect_code) ]

## Positive control mortality
pm = 
  dose3[ control_type == 'P' &
           effect_code == 'MOR' &
           response_unit == '%',
         .(control_pos_mortality = paste(effect_code,
                                         max(gsub('\\+', '', response_mean)),
                                         response_unit,
                                         sep = ' ')),
         .(test_id, response_unit, effect_code) ]

## Vehicle mortality
vm = 
  dose3[ control_type == 'V' &
           effect_code == 'MOR' &
           response_unit == '%',
         .(control_vhc_mortality = paste(effect_code,
                                         max(gsub('\\+', '', response_mean)),
                                         response_unit,
                                         sep = ' ')),
         .(test_id, response_unit, effect_code) ]


# dose response -----------------------------------------------------------
dose2

## drm (129)
dose2[ , dose1_mean := as.numeric(gsub('+|*|NR', '',  dose1_mean)) ]
dose2[ ,
       .(test_id = test_id,
         effect = description)]








