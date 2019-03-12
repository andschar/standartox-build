# script to write variables from final table to shiny directory
# for dynamic shiny UI inputs

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# data --------------------------------------------------------------------
te_fin = readRDS(file.path(cachedir, 'epa3.rds'))

# (2) write variables for shiny UI ----------------------------------------
## preparation
te_stats_l = list(
  ## long variables ----
  tes_effect = out_stats_lng(te_fin, tes_effect),
  tes_endpoint = out_stats_lng(te_fin, tes_endpoint_grp),
  tes_conc_type = out_stats_lng(te_fin, tes_conc1_type),
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
# Effect
te_stats_l$tes_effect[ , variable2 := variable ]

# Endpoint
te_stats_l$tes_endpoint[ , variable2 := variable ]

# Concentration type
te_stats_l$tes_conc_type[ variable == 'A', variable2 := 'Active Ingredient' ]
te_stats_l$tes_conc_type[ variable == 'F', variable2 := 'Formulation' ]
te_stats_l$tes_conc_type[ variable == 'T', variable2 := 'Total (Metals and single elements)' ]
te_stats_l$tes_conc_type[ is.na(variable), variable2 := 'Not assigned' ]
te_stats_l$tes_conc_type[ variable == 'U', variable2 := 'Unionized' ]
te_stats_l$tes_conc_type[ variable == 'L', variable2 := 'Labile' ]
te_stats_l$tes_conc_type[ variable == 'D', variable2 := 'Dissolved' ]

# Continent
te_stats_l$continent[ variable == 'reg_america_north', variable2 := 'North America' ]
te_stats_l$continent[ variable == 'reg_america_south', variable2 := 'South America' ]
te_stats_l$continent[ variable == 'reg_asia', variable2 := 'Asia' ]
te_stats_l$continent[ variable == 'reg_oceania', variable2 := 'Oceania' ]
te_stats_l$continent[ variable == 'reg_europe', variable2 := 'Europe' ]
te_stats_l$continent[ variable == 'reg_africa', variable2 := 'Africa' ]

# Habitat
te_stats_l$habitat[ variable == 'hab_marin', variable2 := 'marine' ]
te_stats_l$habitat[ variable == 'hab_brack', variable2 := 'brackish' ]
te_stats_l$habitat[ variable == 'hab_fresh', variable2 := 'freshwater' ]
te_stats_l$habitat[ variable == 'hab_terre', variable2 := 'terrestrial' ]

# Chemical class
te_stats_l$chem_class[ variable == 'cgr_fungicide', variable2 := 'Fungicides' ]
te_stats_l$chem_class[ variable == 'cgr_herbicide', variable2 := 'Herbicides' ]
te_stats_l$chem_class[ variable == 'cgr_insecticide', variable2 := 'Insecticides' ]
te_stats_l$chem_class[ variable == 'cgr_molluscicide', variable2 := 'Molluscicides' ]
te_stats_l$chem_class[ variable == 'cgr_repellent', variable2 := 'Repellents' ]
te_stats_l$chem_class[ variable == 'cgr_rodenticide', variable2 := 'Rodenticide' ]
te_stats_l$chem_class[ variable == 'cgr_metal', variable2 := 'Metals' ]

# name column -------------------------------------------------------------
lapply(te_stats_l,
       function(dt) dt[ , nam_fin := paste0(variable2, ' - ', perc, '%') ])

# write -------------------------------------------------------------------
# to shinydir
saveRDS(te_stats_l, file.path(shinydata, 'te_stats_l.rds'))

# log ---------------------------------------------------------------------
msg = 'Shiny variables written'
log_msg(msg)

# cleaning ----------------------------------------------------------------
clean_workspace()








