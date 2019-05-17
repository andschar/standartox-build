# script to correct errors in the US EPA ECOTOX data base

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# Error1: 153793 ----------------------------------------------------------
# reference_number: 153793
# the Atrazine values are reported as ppb, although they are ppm
# sent mail to EPA
# ressolved: no

drv = dbDriver("PostgreSQL")
con = dbConnect(drv,
                dbname = DBetox,
                user = DBuser,
                host = DBhost,
                port = DBport,
                password = DBpassword)

dat = dbGetQuery(con, 
                 "SELECT reference_number, res.result_id, tes.test_id, tes.test_characteristics, res.conc1_mean_op, res.conc1_mean, res.conc1_unit, res.conc1_type, endpoint, measurement
                  FROM ecotox.tests tes
                  RIGHT JOIN ecotox.results res on tes.test_id = res.test_id
                  WHERE tes.reference_number = 153793
                  ORDER BY tes.test_characteristics, measurement;")
setDT(dat)

unit = unique(dat[ test_characteristics == 'Atrazine' ]$conc1_unit)

if (unit != 'ppb') {
  message('Units were changed')  
}

test_no = c(801324, 801325, 801326, 801328, 801330)

dbSendQuery(con,
            paste0("UPDATE ecotox.results
                    SET conc1_unit = 'ppm'
                    WHERE result_id IN (", paste0(test_no, collapse = ','), ")"))

dbDisconnect(con)
dbUnloadDriver(drv)
















