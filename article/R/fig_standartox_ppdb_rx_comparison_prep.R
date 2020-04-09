# script to compare STANDARTOX and ppdb results (prepare)
# TODO clean up script

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
ppdb2[, cas := gsub('-', '', cas) ]
# ECOSAR
rx2 = rx[ cas != '' & !is.na(lc50_dm_rx) ]
rx2[ , cas := gsub('-', '', cas) ]
rx2[ , taxon := 'Daphnia magna' ]
rx2[ , dur := 48 ]
setnames(rx2, 'lc50_dm_rx', 'conc_rx')

# merge -------------------------------------------------------------------
dat = merge(stan2, ppdb2, by = c('cas', 'taxon', 'dur'), suffixes = c('_stan', '_ppdb'))
dat[ , diff := abs(conc_stan_gm / conc_ppdb) ]
dat_dm = Reduce(function(...) merge(..., by = c('cas', 'taxon', 'dur'), all = F),
                list(stan2, ppdb2, rx2))
dat_dm[ , diff := abs(conc_stan_gm / conc_rx) ]

# plots -------------------------------------------------------------------
## continuous vs continuous
# NOTE color palette taken from: https://www.datanovia.com/en/blog/top-r-color-palettes-to-know-for-great-data-visualization/
gg1 = ggplot(dat, aes(y = conc_stan_gm, x = conc_ppdb, col = taxon)) +
  geom_point() +
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
  geom_point() +
  geom_abline() +
  geom_abline(intercept = 1, col = 'red') +
  geom_abline(intercept = -1, col = 'red') +
  scale_color_manual(values = '#80B1D3') +
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



stan_oecd_min
# dur: 48, 24, 504, 96









# OLD ---------------------------------------------------------------------

# 
# 
# 
# 
# 
# # function ----------------------------------------------------------------
# ## Base breaks for log10 plots
# base_breaks <- function(n = 10){
#   function(x) {
#     axisTicks(log10(range(x, na.rm = TRUE)), log = TRUE, n = n)
#   }
# }
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# ## plot actual concentrations
# gg_diff = function(dat, xaxis, tax, dur, limits) {
#   
#   dt = dat[ taxon == tax & dur == dur & diff %between% limits ]
#   
#   g1 = ggplot(dt) +
#     geom_pointrange(aes(y = conc_stan_gm, x = reorder(get(xaxis), -conc_stan_gm),
#                         ymin = conc_stan_min,
#                         ymax = conc_stan_max)) +
#     geom_point(aes(y = conc_ppdb, x = get(xaxis), col = 'PPDB')) +
#     scale_y_log10(breaks = scales::log_breaks(n = 10)) +
#     scale_color_manual(name = '', values = c('PPDB' = 'blue')) +
#     scale_fill_manual(name = '', values = c('Standartox' = 'black')) +
#     coord_flip() +
#     # scale_y_continuous(limits = c(0, 1e3)) +
#     labs(y = 'Concentration (ppb)', x = NULL,
#          title = 'Difference STANDARTOX & PPDB',
#          subtitle = tax) +
#     theme_bw() +
#     theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
#     theme(legend.position = 'bottom')
#   
#   return(g1)
# }
# 
# ## plot differences
# gg_diff2 = function(dat, tax, limits) {
#   
#   gg = ggplot(dat[ taxon %in% tax & diff %between% limits ],
#               aes(x = reorder(cas, diff), y = diff,
#                   col = taxon)) +
#     # geom_segment(aes(y = cas, yend = cas, x = 0, xend = diff),
#     #              position = 'dodge') +
#     geom_linerange(aes(ymin = 0, ymax = diff), position = position_dodge(width = 1)) +
#     geom_point(position = position_dodge(width = 1)) +
#     coord_flip() +
#     scale_y_log10() +
#     scale_color_manual(values = names(tax), name = 'Taxon') +
#     theme_bw() +
#     labs(y = '', x = '',
#          title = 'Comparison STANDARTOX & PPDB',
#          subtitle = sprintf('Chemicals for which the LC/EC/LD50 differs by a factor >10',
#                             diff_perc)) +
#     theme(axis.text.x = element_text(angle = 45, hjust = 1))
#   
#   return(gg) 
# }
# 
# 
# 
# 
# 
# # also QSAR ---------------------------------------------------------------
# # TODO rework this
# ## EPA ECOTOX vs Standartox vs PPDB vs RX
# dat_dm_m = melt(dat_dm, measure.vars = c('conc_stan_gm', 'conc_ppdb', 'conc_rx'))
# cas_dat2  = dat_dm$cas
# stan_dm = stan[ taxon == 'Daphnia magna' &
#                   dur == 48 &
#                   cas %in% cas_dat2 ]
# 
# vec =  c(2,10,4,7)
# dat_dm[ , range := diff(range(conc_stan_gm, conc_ppdb, conc_rx)), by = 1:nrow(dat_dm) ]
# dat_dm[ , factor := Reduce(`/`, sort(range(conc_stan_gm, conc_ppdb, conc_rx), decreasing = TRUE)), by = 1:nrow(dat_dm) ]
# dat_dm_m = melt(dat_dm, measure.vars = c('conc_stan_gm', 'conc_ppdb', 'conc_rx'))
# setorder(dat_dm_m, -factor)
# fac10_perc = round(length(which(dat_dm$factor <= 10)) / length(dat_dm$factor) * 100)
# 
# gg = ggplot(dat_dm_m, aes(x = factor)) +
#   geom_density() +
#   geom_rug() +
#   scale_x_continuous(trans = log10_trans(), breaks = base_breaks(),
#                      labels = prettyNum) +
#   labs(title = 'EC50 Daphnia magna tests (48h): Standartox-PPDB-QSAR comparison',
#        subtitle = paste0(fac10_perc, '% differ by less than a factor of 10 (n = 179)'))
# 
# ggsave(gg, filename = file.path(article, 'figures', 'standartox_ppdb_chemprop_comparison.png'),
#        width = 9, height = 6)
# 
# ## OTHER RAMBLINGS
# # ggplot(dat_dm_m, aes(y = reorder(cname, -range), x = range)) +
# #   geom_point() +
# #   scale_x_continuous(trans = log_trans(), breaks = base_breaks(),
# #                      labels = prettyNum)
# # 
# # ggplot(dat_dm_m[1:90], aes(y = cname, x = value, col = variable)) +
# #   geom_point() +
# #   scale_x_log10()
# # 
# # ggplot() +
# #   geom_point(data = stan_dm, aes(y = cname, x = conc_stan)) +
# #   geom_point(data = dat_dm_m, aes(y = reorder(cname, -value), x = value, col = variable)) +
# #   scale_x_log10()
# 
# 
# # absolute vs factorial difference
# # vec = c(4,10,20)
# # diff(range(vec))
# # Reduce(`/`, sort(range(vec), decreasing = TRUE))
# 
# 
# # plotly ------------------------------------------------------------------
# require(plotly)
# 
# dat_dm
# 
# plot_ly(x = dat_dm$conc_ppdb, y = dat_dm$conc_rx, z = dat_dm$conc_stan_gm,
#         type = 'scatter3d',
#         mode = 'markers',
#         color = dat_dm$conc_stan_gm) %>% 
#   layout(xaxis = list(type = 'log'),
#          yaxis = list(type = 'log'),
#          zaxis = list(type = 'log'))
# 
# p <- plot_ly(d, x = ~carat, y = ~price) %>% add_markers()
# 
# plot_ly(dat_dm,
#         x = ~conc_ppdb, y = ~conc_rx, z = ~ ~conc_stan_gm,
#         type = 'scatter3d',
#         mode = 'markers')
# 
# plot_ly(x=temp, y=pressure, z=dtime, type="scatter3d", mode="markers", color=temp)
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# # OLD ---------------------------------------------------------------------
# ## actual concnetrations
# gg_l = list()
# gg_l[[1]] = gg_diff(dat, xaxis = 'cas', tax = 'Daphnia magna', dur = 48, c(5, 1e10))
# names(gg_l)[1] = 'standartox_ppdb_compare_daphnia'
# gg_l[[2]] = gg_diff(dat, xaxis = 'cas', tax = 'Oncorhynchus mykiss', dur = 96, limits)
# names(gg_l)[2] = 'standartox_ppdb_compare_oncorhynchus'
# gg_l[[3]] = gg_diff(dat, xaxis = 'cas', tax = 'Pseudokirchneriella subcapitata', dur = 72, limits)
# names(gg_l)[3] = 'standartox_ppdb_compare_pseudo'
# # save
# for (i in seq_along(gg_l)) {
#   ggsave(gg_l[[i]], filename = file.path(article, 'figures', paste0(names(gg_l)[i], '.png')))
#   saveRDS(gg_l[[i]], file.path(article, 'figures', paste0(names(gg_l)[i], '.rds')))
# }
# 
# ## differences
# # TODO
# # diff_plot = gg_diff2(dat, tax, limits)
# # # save
# # nam = 'Standartox_PPDB'
# # ggsave(diff_plot, filename = file.path(article, 'figures', paste0(nam, '.png')),
# #        width = 10, height = 10)

# 
# 
# # two continous axes ------------------------------------------------------
# #! food for thaught
# # dat2 = dat[ taxon == 'Daphnia magna' ]
# # 
# # ggplot(dat2, aes(y = conc_stan, x = conc_ppdb)) +
# #   geom_point() +
# #   geom_smooth(method = 'lm') +
# #   scale_x_log10() +
# #   scale_y_log10() +
# #   coord_fixed()
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
