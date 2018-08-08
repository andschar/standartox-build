# script to filter the EPA ECOTOX data base test results according to the desired outputs

# setup -------------------------------------------------------------------
source('R/setup.R')
# switches
online = online
online = FALSE

# data --------------------------------------------------------------------
if (online) {
  source('R/re_merge.R')
} else {
  tests_fl = readRDS(file.path(cachedir, 'tests_fl.rds'))
}


# plot --------------------------------------------------------------------
# habitats ----
habitat_stats = tests_fl[ ,
                          .(N_tot = .N,
                            N_marine = .SD[isMar_fin == '1', .N],
                            N_brackish = .SD[isBra_fin == '1', .N],
                            N_freshwater = .SD[isFre_fin == '1', .N],
                            N_terrestrial = .SD[isTer_fin == '1', .N])]
habitat_stats = melt(habitat_stats, value.name = 'N')
habitat_stats[ , perc := N / habitat_stats[variable == 'N_tot', N] * 100 ]

gg_habitat_stats = ggplot(habitat_stats, aes(y = N, x = reorder(variable, N))) +
  geom_bar(stat = 'identity') +
  coord_flip() +
  labs(x = NULL, y = 'N tests') +
  theme_bw()

ggsave(gg_habitat_stats, filename = file.path(plotdir, 'gg_habitat_stats.png'),
       width = 8, height = 5)
# regions ----
region_stats = tests_fl[ ,
                         .(N_tot = .N,
                           N_Africa = .SD[gb_Africa == '1', .N],
                           N_Americas = .SD[gb_Americas == '1', .N],
                           N_Antarctica = .SD[gb_Antarctica == '1', .N],
                           N_Asia = .SD[gb_Asia == '1', .N],
                           N_Europe = .SD[gb_Europe == '1', .N],
                           N_Oceania = .SD[gb_Oceania == '1', .N])]
region_stats = melt(region_stats, value.name = 'N')
region_stats[ , perc := N / region_stats[variable == 'N_tot', N] * 100 ]

gg_region_stats = ggplot(region_stats, aes(y = N, x = reorder(variable, N))) +
  geom_bar(stat = 'identity') +
  coord_flip() +
  labs(x = NULL, y = 'N tests') +
  theme_bw()

ggsave(gg_region_stats, filename = file.path(plotdir, 'gg_region_stats.png'),
       width = 8, height = 5)

# duration ----
duration_stats = tests_fl[ , .N, .(ep_duration, group_fin)]
duration_stats[ , group_fin_maxN := max(N), group_fin]
duration_stats = duration_stats[(N /group_fin_maxN * 100) > 5]

gg_duration_stats1 = ggplot(duration_stats, aes(y = N, x = ep_duration, label = ep_duration)) +
  geom_label() +
  facet_wrap( ~ group_fin, scales = 'free') +
  theme_bw()

gg_duration_stats2 = ggplot(duration_stats, aes(y = N, x = reorder(factor(ep_duration), ep_duration))) +
  geom_bar(stat = 'identity') +
  coord_flip() +
  facet_wrap( ~ group_fin, scales = 'free_x') +
  theme_bw()

ggsave(gg_duration_stats1, filename = file.path(plotdir, 'gg_duration_stats1.png'),
       width = 8, height = 5)
ggsave(gg_duration_stats2, filename = file.path(plotdir, 'gg_duration_stats2.png'),
       width = 8, height = 5)
