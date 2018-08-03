# script to clean the EPA ECOTOX data base test results

# setup -------------------------------------------------------------------
source('R/setup.R')
# switches
online = online
online = FALSE

# data --------------------------------------------------------------------
if (online) {
  source('R/re_merge.R')
} else {
  tests = readRDS(file.path(cachedir, 'test_results.rds'))
}

# varaibles ---------------------------------------------------------------
# water solubility check
tests[ , chck_solub := ifelse(ep_value < pp_solubility_water, TRUE, FALSE)] # TODO check: unit of solubility concentrations

# cleaning ----------------------------------------------------------------
tests_cl = copy(tests)
tests_cl = tests_cl[ !is.na(ep_value) ] # NAs due to merge
tests_cl = tests_cl[ !ep_subst_type %in% c('F')] # F-Formulation, A-Active Ingredient, T-? , U-?
tests_cl = tests_cl[ chck_solub != FALSE ]


# plot --------------------------------------------------------------------
clean_stats = tests[ ,
                     .(N_tot = .N,
                       N_subt_type = .SD[ !ep_subst_type %in% c('F'), .N ],
                       N_solu = .SD[ chck_solub != FALSE, .N ]),
                     ]
clean_stats = melt(clean_stats, value.name = 'N')
clean_stats[ , perc := N / clean_stats[variable == 'N_tot', N] * 100 ]


gg_clean_stats = ggplot(clean_stats, aes(y = N, x = reorder(variable, N))) +
  geom_bar(stat = 'identity') +
  coord_flip() +
  labs(x = NULL, y = 'N tests') +
  theme_bw()

ggsave(gg_clean_stats, filename = file.path(plotdir, 'gg_clean_stats.png'),
       width = 8, height = 5)

# save --------------------------------------------------------------------
saveRDS(tests_cl, file.path(cachedir, 'tests_cl.rds'))


