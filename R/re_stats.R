# script to calculate descriptive statistics for filter test results

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))
source(file.path(src, 'fun_output_stats.R'))

# data --------------------------------------------------------------------
te_fl = readRDS(file.path(cachedir, 'tests_fl.rds'))

# preparation -------------------------------------------------------------

te_stats_l = list(
  ## long variables ----
  ep_effect = data.table(
    nam = out_stats_lng(te_fl, ep_effect)$nam,
    val = out_stats_lng(te_fl, ep_effect)$ep_effect
  ),
  ep_endpoint = data.table(
    nam = out_stats_lng(te_fl, ep_endpoint)$nam,
    val = out_stats_lng(te_fl, ep_endpoint)$ep_endpoint
  ),
  ep_conc_type = data.table(
    nam = out_stats_lng(te_fl, ep_conc_type)$nam,
    val = out_stats_lng(te_fl, ep_conc_type)$ep_conc_type,
    n = out_stats_lng(te_fl, ep_conc_type)$N
  ),
  ## wide variables ----
  continent = out_stats_wid(
    te_fl,
    c('is_america_north', 'is_america_south', 'is_asia', 'is_oceania', 'is_europe', 'is_africa')
  ),
  habitat = out_stats_wid(
    te_fl,
    c('is_marin', 'is_brack', 'is_fresh', 'is_terre')
  )
)

# (2) additions -----------------------------------------------------------

te_stats_l$ep_conc_type[ , nam_long := ifelse(val == 'A', 'Active Ingredient',
                                       ifelse(val == 'F', 'Formulation',
                                       ifelse(val == 'T', 'Total (Metals and single elements)',
                                       ifelse(is.na(val), '',
                                       ifelse(val == 'U', 'Unionized',
                                       ifelse(val == 'L', 'Labile',
                                       ifelse(val == 'D', 'Dissolved', NA))))))) ]

te_stats_l$continent[ , nam_long := ifelse(variable == 'is_america_north', 'North America',
                                    ifelse(variable == 'is_america_south', 'South America',
                                    ifelse(variable == 'is_europe', 'Europe',
                                    ifelse(variable == 'is_asia', 'Asia',
                                    ifelse(variable == 'is_africa', 'Africa',
                                    ifelse(variable == 'is_oceania', 'Oceania', NA)))))) ]
te_stats_l$continent[ , nam_long_stat := paste0(nam_long, ' (', N, ')') ]

te_stats_l$habitat[ , nam_long := ifelse(variable == 'is_marin', 'marin',
                                  ifelse(variable == 'is_brack', 'brackish',
                                  ifelse(variable == 'is_fresh', 'freshwater',
                                  ifelse(variable == 'is_terre', 'terrestrial', NA)))) ]
te_stats_l$habitat[ , nam_long_stat := paste0(nam_long, ' (', N, ')') ]


# write -------------------------------------------------------------------
# to shinydir
saveRDS(te_stats_l, file.path(shinydir, 'data', 'te_stats_l.rds'))







