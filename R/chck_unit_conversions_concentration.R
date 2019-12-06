# script to check concentration and duration units

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# query -------------------------------------------------------------------
# NOTE query to retrieve a sample of the top50 units
q = '
WITH t1 AS (
SELECT conc1_unit, count(*) n
FROM ecotox.results
GROUP BY conc1_unit
ORDER BY n DESC
LIMIT 50
)
SELECT DISTINCT ON (conc1_unit) result_id, conc1_mean, conc1_unit
FROM ecotox.results
RIGHT JOIN t1 USING (conc1_unit)
ORDER BY conc1_unit;
'

# sample ------------------------------------------------------------------
# 50 most occurring result_id s
ids = c(2227707L, 2144511L, 1177875L, 1012510L, 2267424L, 1059003L, 
        2109679L, 2459421L, 1145750L, 1165988L, 2262868L, 2179588L, 2117263L, 
        1172177L, 798810L, 2453697L, 2345310L, 1128312L, 1039743L, 775822L, 
        206500L, 1042482L, 2295969L, 2371433L, 1117335L, 1228663L, 1065969L, 
        168785L, 1186575L, 1138853L, 1153817L, 244062L, 2074585L, 2226852L, 
        239960L, 2126050L, 2287429L, 1110015L, 2060384L, 1190262L, 2333451L, 
        1189176L, 1050168L, 88612L, 2248365L, 1219977L, 55416L, 1219748L, 
        2229405L, 2348737L, 756609L)

q = paste0("SELECT stx.result_id, stx.casnr, che.molecularweight, stx.conc1_mean, stx.conc1_unit, stx.conc1_mean2, stx.conc1_unit2,
conv, conc1_info, conc1_unit_clean, multiplier, unit_conv, unit_type
            FROM standartox.tests stx
            LEFT JOIN standartox.chemicals che ON stx.casnr = che.casnr
            LEFT JOIN lookup.concentration_unit_lookup using(conc1_unit)
            WHERE stx.result_id IN (", paste0(ids, collapse = ','), ")
              AND conc1_mean != 'NR';")

conc = read_query(user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
                 query = q)

# manual comparison -------------------------------------------------------
conc[ result_id ==  55416L, `:=` (conc1_mean3 = 1.17, conc1_unit3 = 'ul/l') ]
conc[ result_id ==  88612L, `:=` (conc1_mean3 = 1000, conc1_unit3 = 'ug/l') ]
conc[ result_id ==  168785L, `:=` (conc1_mean3 = 110, conc1_unit3 = 'ug/l') ]
conc[ result_id ==  206500L, `:=` (conc1_mean3 = 15, conc1_unit3 = 'mg/kg bdwt/d') ]
conc[ result_id ==  239960L, `:=` (conc1_mean3 = 100, conc1_unit3 = 'ppb') ]
conc[ result_id ==  244062L, `:=` (conc1_mean3 = 45830, conc1_unit3 = 'ug/l') ]
conc[ result_id ==  775822L, `:=` (conc1_mean3 = 50, conc1_unit3 = 'mg/kg') ]
conc[ result_id ==  798810L, `:=` (conc1_mean3 = 0.003, conc1_unit3 = 'g/m2') ]
conc[ result_id == 1012510L, `:=` (conc1_mean3 = 0.015, conc1_unit3 = 'g/m2') ]
conc[ result_id == 1039743L, `:=` (conc1_mean3 = 18.8, conc1_unit3 = 'mg/kg') ]
conc[ result_id == 1042482L, `:=` (conc1_mean3 = 5, conc1_unit3 = 'mg/kg/d') ]
conc[ result_id == 1050168L, `:=` (conc1_mean3 = 0.048, conc1_unit3 = 'mg/kg') ]
conc[ result_id == 1059003L, `:=` (conc1_mean3 = 0.5, conc1_unit3 = 'g/m2') ]
conc[ result_id == 1065969L, `:=` (conc1_mean3 = 2, conc1_unit3 = 'mg/kg') ]
conc[ result_id == 1110015L, `:=` (conc1_mean3 = 320, conc1_unit3 = 'ug') ]
conc[ result_id == 1117335L, `:=` (conc1_mean3 = 100, conc1_unit3 = 'mg/kg') ]
conc[ result_id == 1128312L, `:=` (conc1_mean3 = 283.79, conc1_unit3 = 'ug/l') ]
conc[ result_id == 1138853L, `:=` (conc1_mean3 = 150000, conc1_unit3 = 'ul/l') ]
conc[ result_id == 1145750L, `:=` (conc1_mean3 = 658300, conc1_unit3 = 'ppb') ]
conc[ result_id == 1153817L, `:=` (conc1_mean3 = 3999.7, conc1_unit3 = 'ug/l') ]
conc[ result_id == 1165988L, `:=` (conc1_mean3 = 592000, conc1_unit3 = 'ppb') ]
conc[ result_id == 1172177L, `:=` (conc1_mean3 = 30000000, conc1_unit3 = 'ug/l') ]
conc[ result_id == 1177875L, `:=` (conc1_mean3 = 10, conc1_unit3 = '%') ]
conc[ result_id == 1186575L, `:=` (conc1_mean3 = 2000000, conc1_unit3 = 'ug/l') ]
conc[ result_id == 1219977L, `:=` (conc1_mean3 = 10, conc1_unit3 = 'ug/org') ] # microgram/organism
conc[ result_id == 2060384L, `:=` (conc1_mean3 = 0.0009, conc1_unit3 = 'g/m2') ]
conc[ result_id == 2074585L, `:=` (conc1_mean3 = 0.01, conc1_unit3 = 'ug/l') ]
conc[ result_id == 2109679L, `:=` (conc1_mean3 = 0.00571631803125098, conc1_unit3 = 'g/m2') ]
conc[ result_id == 2117263L, `:=` (conc1_mean3 = 0.05686, conc1_unit3 = 'g/m2') ]
conc[ result_id == 2126050L, `:=` (conc1_mean3 = 80000, conc1_unit3 = 'ppb') ]
conc[ result_id == 2144511L, `:=` (conc1_mean3 = 106400, conc1_unit3 = 'ug/l') ]
conc[ result_id == 2226852L, `:=` (conc1_mean3 = 0.2724, conc1_unit3 = 'ug/l') ]
conc[ result_id == 2227707L, `:=` (conc1_mean3 = 0.1, conc1_unit3 = '%') ]
conc[ result_id == 2229405L, `:=` (conc1_mean3 = 4911, conc1_unit3 = 'ug/l') ]
conc[ result_id == 2248365L, `:=` (conc1_mean3 = 10000, conc1_unit3 = 'ug/l') ]
conc[ result_id == 2262868L, `:=` (conc1_mean3 = 0.305, conc1_unit3 = 'ug/l') ]
conc[ result_id == 2267424L, `:=` (conc1_mean3 = 700000, conc1_unit3 = 'ug/l') ]
conc[ result_id == 2287429L, `:=` (conc1_mean3 = 720000, conc1_unit3 = 'ppb') ]
conc[ result_id == 2295969L, `:=` (conc1_mean3 = 1.25, conc1_unit3 = 'mg/kg') ]
conc[ result_id == 2333451L, `:=` (conc1_mean3 = 45, conc1_unit3 = 'mg/kg') ]
conc[ result_id == 2345310L, `:=` (conc1_mean3 = 0.8, conc1_unit3 = 'ml/m2') ]
conc[ result_id == 2348737L, `:=` (conc1_mean3 = 1, conc1_unit3 = '% v/v') ]
conc[ result_id == 2371433L, `:=` (conc1_mean3 = 100, conc1_unit3 = 'mg/kg') ]
conc[ result_id == 2453697L, `:=` (conc1_mean3 = 0.112084667279431, conc1_unit3 = 'g/m2') ]
conc[ result_id == 756609L, `:=` (conc1_mean3 = 1.7621, conc1_unit3 = 'mg/kg') ]

# chck --------------------------------------------------------------------
chck_conc1_mean2 = conc[ conc1_mean2 != conc1_mean3 ]
chck_conc1_unit2 = conc[ conc1_unit2 != conc1_unit3 ]

if (nrow(chck_conc1_mean2) != 0) {
  msg = 'Concentration conversion (conc1_mean2) not valid.'
  warning(msg)
  log_msg(msg)
}
if (nrow(chck_conc1_unit2) != 0) {
  msg = 'Concentration conversion (conc1_unit2) not valid.'
  warning(msg)
  log_msg(msg)
}

# write -------------------------------------------------------------------
fwrite(conc, file.path(article, 'cache', 'chck-units-concentration.csv'))

# log ---------------------------------------------------------------------
log_msg('CHCK: Concentration units conversions check script run.')

# cleaning ----------------------------------------------------------------
clean_workspace()

