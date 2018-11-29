# script to write table to shiny directory

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))
source(file.path(src, 'fun_shiny_variables_stat.R'))

# data --------------------------------------------------------------------
tests_fin = readRDS(file.path(cachedir, 'tests_fin.rds'))

# (1) write table to shiny directory --------------------------------------
## as .rds
time = Sys.time()
saveRDS(tests_fin, file.path(shinydata, 'tests_fin.rds'))
Sys.time() - time
## as feather
time = Sys.time()
write_feather(tests_fin, file.path(shinydata, 'tests_fin.feather'))
Sys.time() - time
## copy .feather via scp to server (github only allows 100MB)
#! takes some time
if (nodename == 'scharmueller' & scp_feather) {
  system(
    paste('scp',
          file.path(shinydata, 'tests_fin.feather'),
          'scharmueller@139.14.20.252:/home/scharmueller/Projects/etox-base-shiny/data/tests_fin.feather',
          sep = ' ')
  )
}

# log
msg = paste0('Final table (tests_fin) written to shiny data dir:\n', shinydata)
log_msg(msg); rm(msg)

# (2) write variables for shiny UI ----------------------------------------
## preparation
te_stats_l = list(
  ## long variables ----
  tes_effect = data.table(
    nam = out_stats_lng(te_fin, tes_effect)$nam,
    val = out_stats_lng(te_fin, tes_effect)$tes_effect
  ),
  tes_endpoint = data.table(
    nam = out_stats_lng(te_fin, tes_endpoint)$nam,
    val = out_stats_lng(te_fin, tes_endpoint)$tes_endpoint
  ),
  tes_conc_type = data.table(
    nam = out_stats_lng(te_fin, tes_conc_type)$nam,
    val = out_stats_lng(te_fin, tes_conc_type)$tes_conc_type,
    n = out_stats_lng(te_fin, tes_conc_type)$N
  ),
  ## wide variables ----
  continent = out_stats_wid(
    te_fin,
    c('reg_america_north', 'reg_america_south', 'reg_asia', 'reg_oceania', 'reg_europe', 'reg_africa')
  ),
  habitat = out_stats_wid(
    te_fin,
    c('hab_marin', 'hab_brack', 'hab_fresh', 'hab_terre')
  ),
  chem_class = out_stats_wid(
    te_fin,
    c('cgr_fungicide', 'cgr_herbicide', 'cgr_insecticide', 'cgr_molluscicide', 
      'cgr_repellent', 'cgr_rodenticide', 'cgr_metal')
    
  )
)

## additions
te_stats_l$tes_conc_type[ , nam_long := ifelse(val == 'A', 'Active Ingredient',
                                               ifelse(val == 'F', 'Formulation',
                                                      ifelse(val == 'T', 'Total (Metals and single elements)',
                                                             ifelse(is.na(val), '',
                                                                    ifelse(val == 'U', 'Unionized',
                                                                           ifelse(val == 'L', 'Labile',
                                                                                  ifelse(val == 'D', 'Dissolved', NA))))))) ]

te_stats_l$continent[ , nam_long := ifelse(variable == 'reg_america_north', 'North America',
                                           ifelse(variable == 'reg_america_south', 'South America',
                                                  ifelse(variable == 'reg_europe', 'Europe',
                                                         ifelse(variable == 'reg_asia', 'Asia',
                                                                ifelse(variable == 'reg_africa', 'Africa',
                                                                       ifelse(variable == 'reg_oceania', 'Oceania', NA)))))) ]
te_stats_l$continent[ , nam_long_stat := paste0(nam_long, ' (', N, ')') ]

te_stats_l$habitat[ , nam_long := ifelse(variable == 'hab_marin', 'marin',
                                         ifelse(variable == 'hab_brack', 'brackish',
                                                ifelse(variable == 'hab_fresh', 'freshwater',
                                                       ifelse(variable == 'hab_terre', 'terrestrial', NA)))) ]
te_stats_l$habitat[ , nam_long_stat := paste0(nam_long, ' (', N, ')') ]

te_stats_l$chem_class[ , nam_long := ifelse(variable == 'cgr_fungicide', 'Fungicides',
                                            ifelse(variable == 'cgr_herbicide', 'Herbicides',
                                                   ifelse(variable == 'cgr_insecticide', 'Insecticides',
                                                          ifelse(variable == 'cgr_molluscicide', 'Molluscicides',
                                                                 ifelse(variable == 'cgr_repellent', 'Repellents',
                                                                        ifelse(variable == 'cgr_rodenticide', 'Rodenticides',
                                                                               ifelse(variable == 'cgr_metal', 'Metals', NA))))))) ]
te_stats_l$chem_class[ , nam_long_stat := paste0(nam_long, ' (', N, ')') ]

# write -------------------------------------------------------------------
# to shinydir
saveRDS(te_stats_l, file.path(shinydata, 'te_stats_l.rds'))

# log ---------------------------------------------------------------------
msg = 'Shiny variables written'
log_msg(msg); rm(msg)










