# script to compare STANDARTOX and ppdb results (prepare)

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))
tax = c('Daphnia magna', 'Oncorhynchus mykiss', 'Pseudokirchneriella subcapitata')
names(tax) = c('#F8766D', '#619CFF', '#00BA38')
limits = c(1e1, 1e10)

# data --------------------------------------------------------------------
stan = readRDS(file.path(cachedir, 'ar_standartox_comparison_stan.rds'))
ppdb = readRDS(file.path(cachedir, 'ar_standartox_comparison_ppdb.rds'))
rx = readRDS(file.path(cachedir, 'ar_standartox_comparison_rx.rds'))

# errata ------------------------------------------------------------------
ppdb[ taxon == c('Raphidocelis subcapitata'), taxon := 'Pseudokirchneriella subcapitata' ]

# prepare -----------------------------------------------------------------
# Standartox
stan2 = stan[ conc_unit_stan %in% c('ug/l', 'ppb'),
              .(conc_stan_min = min(conc_stan, na.rm = TRUE),
                conc_stan_gm = gm_mean(conc_stan, na.rm = TRUE),
                conc_stan_max = max(conc_stan, na.rm = TRUE),
                n = .N),
              .(cas, cname, taxon, dur) ]
stan2 = na.omit(stan2)
# PPDB
ppdb2 = ppdb[ endpoint %in% c('LC50', 'LD50', 'EC50') ]
# ECOSAR
rx2 = rx[ cas != '' & !is.na(lc50_dm_rx) ]
rx2[ , taxon := 'Daphnia magna' ]
rx2[ , dur := 48 ]
setnames(rx2, 'lc50_dm_rx', 'conc_rx')

# merge -------------------------------------------------------------------
dat = merge(stan2, ppdb2, by = c('cas', 'taxon', 'dur'), suffixes = c('_stan', '_ppdb'))
taxa = dat[ , .N, taxon ][ order(-N) ][ 1:8, taxon ] # 8 most ocurring taxa
dat = dat[ taxon %in% taxa ]
dat[ , diff := abs(conc_stan_gm / conc_ppdb) ]
dat_dm = Reduce(function(...) merge(..., by = c('cas', 'taxon', 'dur'), all = F),
                list(stan2, ppdb2, rx2))
dat_dm[ , diff := abs(conc_stan_gm / conc_rx) ]

# plots -------------------------------------------------------------------
## continuous vs continuous
# NOTE color palette taken from: https://www.datanovia.com/en/blog/top-r-color-palettes-to-know-for-great-data-visualization/
gg1 = ggplot(dat, aes(y = conc_stan_gm, x = conc_ppdb, col = taxon)) +
  geom_point(size = 2.5) +
  geom_abline() +
  geom_abline(intercept = 1, col = 'red') +
  geom_abline(intercept = -1, col = 'red') +
  scale_color_brewer(palette = "Set3") +
  scale_y_log10(breaks = trans_breaks("log10", function(x) 10^x),
                labels = trans_format("log10", math_format(10^.x))) +
  scale_x_log10(breaks = trans_breaks("log10", function(x) 10^x),
                labels = trans_format("log10", math_format(10^.x))) +
  # coord_fixed() +
  labs(y = 'Standartox',
       x = 'PPDB') +
  theme(legend.text = element_text(face = 'italic'),
        legend.title = element_blank())

gg2 = ggplot(dat_dm, aes(y = conc_stan_gm, x = conc_rx, col = taxon)) +
  geom_point(size = 2.5) +
  geom_abline() +
  geom_abline(intercept = 1, col = 'red') +
  geom_abline(intercept = -1, col = 'red') +
  scale_color_manual(values = '#BEBADA') +
  scale_y_log10(breaks = trans_breaks("log10", function(x) 10^x),
                labels = trans_format("log10", math_format(10^.x))) +
  scale_x_log10(breaks = trans_breaks("log10", function(x) 10^x),
                labels = trans_format("log10", math_format(10^.x))) +
  # coord_fixed() +
  labs(y = 'Standartox',
       x = 'ChemProp') +
  theme(legend.text = element_text(face = 'italic'),
        legend.title = element_blank())

prow = plot_grid(gg1 + theme(legend.position="none"),
                 gg2 + theme(legend.position="none"),
                 align = 'vh',
                 labels = c("A", "B"),
                 hjust = -1,
                 nrow = 1)
legend = get_legend(gg1 + theme(legend.position = c(0.3, 0.35),
                                legend.box.margin = margin(0, 0, 0, -12)))
gg_ppdb_rx_stan = plot_grid(prow, legend, rel_widths = c(3, .4))

# table -------------------------------------------------------------------
dt = dat[ ,
          .(n_tot = .N,
            n_10 = .SD[ diff > 10, .N ],
            n_tot_5tests = .SD[ n >= 5, .N],
            n_10_5tests = .SD[ n >= 5 & diff > 10, .N],
            n_tot_10tests = .SD[ n >= 10, .N],
            n_10_10tests = .SD[ n >= 10 & diff > 10, .N]) ]
dt[ , perc_10 := round(n_10 / n_tot * 100, 1) ]
dt[ , perc_10_5tests := round(n_10_5tests / n_tot_5tests * 100, 1) ]
dt[ , perc_10_10tests := round(n_10_10tests / n_tot_10tests * 100, 1) ]

dt_dm = dat_dm[ ,
                .(n_tot = .N,
                  n_10 = .SD[ diff > 10, .N ],
                  n_tot_5tests = .SD[ n >= 5, .N],
                  n_10_5tests = .SD[ n >= 5 & diff > 10, .N],
                  n_tot_10tests = .SD[ n >= 10, .N],
                  n_10_10tests = .SD[ n >= 10 & diff > 10, .N]) ]
dt_dm[ , perc_10 := round(n_10 / n_tot * 100, 1) ]
dt_dm[ , perc_10_5tests := round(n_10_5tests / n_tot_5tests * 100, 1) ]
dt_dm[ , perc_10_10tests := round(n_10_10tests / n_tot_10tests * 100, 1) ]

tab = rbindlist(list(ppdb = dt,
                     rx = dt_dm),
                idcol = 'source')

# write -------------------------------------------------------------------
ggsave(plot = gg_ppdb_rx_stan,
       file.path(article, 'figures', 'gg_ppdb_stan_compare_continous.png'),
       width = 14, height = 6)
fwrite(tab, file.path(article, 'tables', 'standartox_ppdb.csv'))

# log ---------------------------------------------------------------------
log_msg('ARTICLE: FIGURE: ~/gg_ppdb_stan_compare_continous.png created.')

# cleaning ----------------------------------------------------------------
clean_workspace()

stan3 = stan[ taxon == 'Daphnia magna' &
                endpoint == 'XX50' &
                effect %in% c('Intoxication', 'Mortality') &
                dur == 48 ]
stan3[ , n := .N, .(cas, cname, dur) ]
stan3 = stan3[ n >= 5 ]

stan3[ , .N, effect ][ order(-N) ] 

stan_gm = stan3[ ,
                 .(gm = gm_mean(conc_stan)),
                 .(cas, cname, dur) ]

stan_oecd_min = stan3[ grep('OECD', test_method),
                       .(min_oecd = min(conc_stan)),
                       .(cas, cname, dur) ]
ppdb3 = ppdb[ endpoint %in% c('EC50', 'LC50') &
                taxon == 'Daphnia magna' &
                dur == 48 ]
ppdb3[ , cas := gsub('-', '', cas) ]

stan_oecd = merge(stan_gm, stan_oecd_min, by = c('cas', 'cname', 'dur'))

stan_oecd_m = melt(stan_oecd,
                   id.vars = c('cas', 'cname', 'dur'))
ggplot() +
  geom_point(data = stan3[ cas %in% stan_oecd$cas ],
             aes(y = reorder(cname, -conc_stan), x = conc_stan)) +
  geom_point(data = stan_oecd_m, aes(y = cname, x = value, col = variable)) +
  geom_point() +
  scale_x_log10() +
  theme(axis.title.y = element_blank())

# log ---------------------------------------------------------------------
log_msg('ARTICLE: FIGURE: ~/results_variability.png created.')

# cleaning ----------------------------------------------------------------
clean_workspace()
