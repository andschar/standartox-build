# script to clean the EPA ECOTOX data base test results

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# data --------------------------------------------------------------------
tests_fl_stat = readRDS(file.path(cachedir, 'tests_fl.rds'))
rows_cas = nrow(tests_fl_stat[ , unique(.SD), .SDcols = 'cas' ])
rows_tax = nrow(tests_fl_stat[ , unique(.SD), .SDcols = 'taxon' ])

# functions ---------------------------------------------------------------
chck_na_cas = function (dt, var) { dt[ is.na(get(var)), unique(.SD), .SDcols = c('cas', var) ] }
chck_na_tax = function (dt, var) { dt[ is.na(get(var)), unique(.SD), .SDcols = c('taxon', var) ] }

# chemical variables ------------------------------------------------------
chem_vars = c('cas', 'comp_name', 'comp_type', 'comp_solub')
na_chem_l = mapply(chck_na_cas, chem_vars, MoreArgs = list(dt = tests_fl_stat), SIMPLIFY = FALSE)

chem_missing = data.table(
  variable = names(sapply(na_chem_l, nrow)),
  missing = sapply(na_chem_l, nrow),
  n = rows_cas
)
chem_missing[ , perc := round(missing / n, 2) ]


# taxonomic variables -----------------------------------------------------
taxa_missing = data.table(NA)


# habitat variables -------------------------------------------------------
habitat_vars = c('isMar_fin', 'isBra_fin', 'isFre_fin', 'isTer_fin')

# (1)
habi = tests_fl_stat[ , lapply(.SD, mean), by = taxon, .SDcols = habitat_vars ]
habi[ , variable := rowSums(.SD, na.rm = TRUE), .SDcols = habitat_vars ] # column with all combined
habi_missing1 = habi[ , .(missing = .N), variable ][ variable == 0 ]
habi_missing1[ , n := rows_tax ][ , perc := round(missing / n,2) ]
habi_missing1[ , variable := 'is_habi_all' ]

# (2)
na_habi_l = mapply(chck_na_tax, habitat_vars, MoreArgs = list(dt = tests_fl_stat), SIMPLIFY = FALSE)

habi_missing2 = data.table(
  variable = names(sapply(na_habi_l, nrow_perc)),
  missing = sapply(na_habi_l, nrow),
  n = rows_tax
)
habi_missing2[ , perc := round(missing / n, 2) ]
habi_missing = rbindlist(list(habi_missing1, habi_missing2))

# region variables --------------------------------------------------------
continent_vars = c('is_africa', 'is_america_north', 'is_america_south', 'is_asia', 'is_europe', 'is_oceania')

# (1)
cont = tests_fl_stat[ , lapply(.SD, mean), by = taxon, .SDcols = continent_vars ]
cont[ , variable := rowSums(.SD, na.rm = TRUE), .SDcols = continent_vars ] # column with all combined
cont_missing1 = cont[ , .(missing = .N), variable ][ variable == 0 ]
cont_missing1[ , n := rows_tax ][ , perc := round(missing / n,2) ]
cont_missing1[ , variable := 'is_cont_all' ]

# (2)
na_cont_l = mapply(chck_na_tax, continent_vars, MoreArgs = list(dt = tests_fl_stat), SIMPLIFY = FALSE)

cont_missing2 = data.table(
  variable = names(sapply(na_cont_l, nrow)),
  missing = sapply(na_cont_l, nrow),
  n = rows
)
cont_missing2[ , perc := round(missing / n, 2) ]
cont_missing = rbindlist(list(cont_missing1, cont_missing2))

# authorized --------------------------------------------------------------



# write to file -----------------------------------------------------------
missing_l = list(chem_missing = chem_missing,
                 taxa_missing = taxa_missing,
                 habi_missing = habi_missing,
                 cont_missing = cont_missing)

missing_dt = rbindlist(missing_l, fill = TRUE, idcol = 'group')[ , V1 := NULL ]

fwrite(missing_dt, file.path(cachedir, 'tests_fl_stat.csv'))





