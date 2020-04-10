# script that fetches important values for the publication

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# (1) publishing rate -----------------------------------------------------
q = "SELECT published_date, count(*) n 
     FROM ecotox.tests
     GROUP BY published_date
     ORDER BY n desc"

dat = read_query(user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
                 query = q)
dat[ , published_date := as.Date(published_date, format = '%m/%d/%Y') ]
setorder(dat, -published_date)
dat = na.omit(dat)
dat14 = dat[ published_date %between% c('2014-01-01', '2019-12-31') ]
publishing_rate = round(mean(dat14$n))

# (2) ecotox-standartox size ----------------------------------------------
q = "SELECT 'Ecotox' db, count(*) n
     FROM ecotox.results
     UNION ALL
     SELECT 'Standartox' db, count(*) n
     FROM standartox.tests_fin"
size = read_query(user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
                  query = q)
size[ , perc := floor(size$n[2] / size$n[1] * 100) ]

# (3) count concentration & duration units --------------------------------
q = "SELECT 'Ecotox' db, count(*) n
     FROM (SELECT DISTINCT conc1_unit FROM ecotox.results) AS t1
     UNION ALL
     SELECT 'Standartox' db, count(*) n
     FROM (SELECT DISTINCT concentration_unit FROM standartox.tests_fin) AS t1"
conc_unit = read_query(user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
                       query = q)
conc_unit[ , perc := round(conc_unit$n[2] / conc_unit$n[1] * 100, 1) ]

# (4) kept chem -----------------------------------------------------------
q = "SELECT 'Ecotox' db, count(*) n
     FROM (SELECT DISTINCT test_cas FROM ecotox.tests) AS tmp
     UNION ALL
     SELECT 'Standartox' db, count(*) n
     FROM (SELECT DISTINCT casnr FROM standartox.tests_fin) AS tmp"
cas = read_query(user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
                 query = q)
cas[ , perc := round(cas$n[2] / cas$n[1] * 100, 1) ]

# (5) kept taxa -----------------------------------------------------------
q = "SELECT 'Ecotox' db, count(*) n
     FROM (SELECT DISTINCT species_number FROM ecotox.tests) AS tmp
     UNION ALL
     SELECT 'Standartox' db, count(*) n
     FROM (SELECT DISTINCT species_number FROM standartox.tests_fin) AS tmp"
tax = read_query(user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
                 query = q)
tax[ , perc := round(tax$n[2] / tax$n[1] * 100, 1) ]

# FIN: compile values -----------------------------------------------------
iv = list(publishing_rate = publishing_rate,
          size = size,
          conc_unit = conc_unit,
          cas = cas,
          tax = tax)

# write -------------------------------------------------------------------
write_json(iv, file.path('values', 'important_values.json'))

# log ---------------------------------------------------------------------
log_msg('ARTICLE: important values compiled.')

# cleaning ----------------------------------------------------------------
clean_workspace()
