# script to visualize variability in ecotoxicological test data
# NOTE ggridges:: options out-commented
# NOTE other dwellings at the end

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
q = "SELECT cas, cname, tax_taxon taxon, concentration, concentration_unit, duration, duration_unit, endpoint, effect
     FROM standartox.data2
     WHERE duration_unit = 'h'"

dat = read_query(user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
                 query = q)

# erros -------------------------------------------------------------------
# TODO fix this before
dat[ taxon == 'Pseudokirchneriella subcapitata', taxon := 'Raphidocelis subcapitata' ]

# prepare -----------------------------------------------------------------
dat2 = dat[ taxon %in% c('Raphidocelis subcapitata', 'Lemna minor', 'Oncorhynchus mykiss', 'Rattus norvegicus', 'Xenopus laevis', 'Daphnia magna', 'Pimephales promelas') &
              endpoint == 'XX50' &
              concentration_unit %in% c('ug/l', 'ppb') &
              duration %in% c(24,48,72,96) ]
dat2[ , duration := as.factor(duration) ]

# functions ---------------------------------------------------------------
base_breaks = function(n = 10) {
  function(x) {
    axisTicks(log10(range(x, na.rm = TRUE)), log = TRUE, n = n)
  }
}

# variability due to species ----------------------------------------------
tax = dat2[ cname == 'atrazine' &
              duration == 96 &
              !taxon %in% c('Daphnia magna', 'Pimephales promelas') ]

tax[ taxon == 'Raphidocelis subcapitata', taxon := 'R. subcapitata' ] %>% 
  .[ taxon == 'Lemna minor', taxon := 'L. minor' ] %>% 
  .[ taxon == 'Oncorhynchus mykiss', taxon := 'O. mykiss' ] %>% 
  .[ taxon == 'Xenopus laevis', taxon := 'X. laevis' ]

tax_gm = tax[ ,
              .(min = min(concentration),
                gm = gm_mean(concentration),
                max = max(concentration)),
              .(taxon) ]

gg_tax = ggplot(tax, aes(x = taxon, y = concentration)) +
  geom_point(position = position_jitter(seed = 1234)) +
  geom_violin(position = position_dodge(), alpha = 0.5) +
  geom_point(data = tax_gm, aes(x = taxon, y = gm), size = 3, col = viridis_pal()(1)) +
  geom_point(data = tax_gm, aes(x = taxon, y = min), size = 1.5, col = 'black') +
  geom_point(data = tax_gm, aes(x = taxon, y = max), size = 1.5, col = 'black') +
  scale_y_log10(breaks = c(10, 100, 1000, 10000),
                labels = c(10, 100, 1000, 10000),
                limits = c(1, 100000)) +
  coord_flip() +
  theme(axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text.y = element_text(face = 'italic'))

## ggrigdes code
# gg_tax = ggplot(tax, aes(y = taxon, x = concentration)) +
#   geom_density_ridges(jittered_points = TRUE,
#                       position = position_points_sina(seed = 1234),
#                       point_size = 1, point_alpha = 1, alpha = 0.4, fill = NA) +
#   scale_x_continuous(trans = log_trans(), breaks = base_breaks(),
#                      labels = prettyNum) +
#   labs(# title = 'Atrazine',
#        # subtitle = 'XX50 endpoint, 96 hour tests',
#        x = 'Concentration (ug/l)',
#        y = NULL) +
#   theme(axis.title.x = element_blank())
### END

# variability due to test duration ----------------------------------------
dur = dat2[ taxon == 'Daphnia magna' &
              cas == '7733020' ] # zinc sulfate
dur_gm = dur[ ,
              .(min = min(concentration),
                gm = gm_mean(concentration),
                max = max(concentration)),
              .(taxon, duration) ]

gg_dur = ggplot(dur, aes(x = duration, y = concentration)) +
  geom_point(position = position_jitter(seed = 1234)) +
  geom_violin(position = position_dodge(), alpha = 0.5) +
  geom_point(data = dur_gm, aes(x = duration, y = gm), size = 3, col = viridis_pal()(1)) +
  geom_point(data = dur_gm, aes(x = duration, y = min), size = 1.5, col = 'black') +
  geom_point(data = dur_gm, aes(x = duration, y = max), size = 1.5, col = 'black') +
  scale_y_log10(breaks = c(10, 100, 1000, 10000),
                labels = c(10, 100, 1000, 10000),
                limits = c(1, 100000)) +
  # coord_cartesian(ylim = c(0, 10000)) +
  # ylim(0, 10000) +
  coord_flip() +
  theme(axis.title.x = element_blank(),
        axis.title.y = element_blank())

## ggrigdes code
# gg_dur = ggplot(dur, aes(y = as.factor(duration), x = concentration)) +
#   geom_vline(data = dur_gm, aes(xintercept = gm, group = as.factor(duration))) +
#   geom_density_ridges(jittered_points = TRUE,
#                       position = position_points_sina(seed = 1234),
#                       point_size = 1, point_alpha = 1, alpha = 0.4, fill = NA) +
#   scale_x_continuous(trans = log_trans(), breaks = base_breaks(),
#                      labels = prettyNum) + 
#   labs(# title = 'Zinc sulfate Daphnia magna test results',
#        # subtitle = 'XX50 endpoint, 96 hour tests',
#        x = 'Concentration (ug/l)',
#        y = NULL) +
#   theme(axis.title.x = element_blank())
### END

# variability due to different laboratories -------------------------------
lab = dat2[ effect == 'Mortality' &
              cas == '7758987' & # cupric sulfate
              taxon == 'Pimephales promelas' &
              duration == 96 ] # most tests
lab[ , cname := '  ' ] # HACK
lab_gm = lab[ ,
              .(min = min(concentration),
                gm = gm_mean(concentration),
                max = max(concentration)),
              .(taxon, cname) ]

gg_lab = ggplot(lab, aes(x = cname, y = concentration)) +
  geom_point(position = position_jitter(seed = 1234)) +
  geom_violin(position = position_dodge(), alpha = 0.5) +
  geom_point(data = lab_gm, aes(x = cname, y = gm), size = 3, col = viridis_pal()(1)) +
  geom_point(data = lab_gm, aes(x = cname, y = min), size = 1.5, col = 'black') +
  geom_point(data = lab_gm, aes(x = cname, y = max), size = 1.5, col = 'black') +
  scale_y_log10(breaks = c(10, 100, 1000, 10000),
                labels = c(10, 100, 1000, 10000),
                limits = c(1, 100000)) +
  coord_flip() +
  theme(axis.title.x = element_blank(),
        axis.text.x = element_text(),
        axis.title.y = element_blank())

## ggrigdes code
# gg_lab = ggplot(lab, aes(y = cname, x = concentration)) +
#   geom_density_ridges(jittered_points = TRUE,
#                       position = position_points_sina(seed = 1234),
#                       point_size = 1, point_alpha = 1, alpha = 0.4, fill = NA) +
#   scale_x_continuous(trans = log_trans(), breaks = base_breaks(),
#                      labels = prettyNum) + 
#   labs(# title = 'Cupric sulfate Pimephales promelas test results',
#        # subtitle = 'XX50 endpoint, 96 hour tests',
#        x = 'Concentration (ug/l)',
#        y = NULL) +
#   theme(axis.title.x = element_blank(),
#         axis.text.y = element_blank())
### END

# combine variability plots -----------------------------------------------
# gg_var = plot_grid(gg_var_lab, gg_var_taxc, gg_var_dur,
#                    labels = 'AUTO',
#                    align = 'vh')
# title = ggdraw() + draw_label('Variabilit') # TODO add title ?
left = plot_grid(gg_tax,
                 ncol = 1, labels = 'AUTO')
right = plot_grid(gg_dur, gg_lab,
                  nrow = 2,
                  labels = c('B', 'C'),
                  align = 'v')
# TODO add title
gg_var = plot_grid(left, right,
                   ncol = 2, 
                   rel_heights = c(0.2, 1),
                   rel_widths = c(0.5, 0.5))
gg_var = ggdraw(add_sub(gg_var,
                        "Concentration (µg/l)",
                        y = 1,
                        x = 0.5,
                        vjust = 1.5))

# write -------------------------------------------------------------------
ggsave(gg_var, filename = file.path(article, 'figures', 'results_variability.png'),
       width = 11, height = 11)

# log ---------------------------------------------------------------------
log_msg('ARTICLE: FIGURE: ~/results_variability.png created.')

# cleaning ----------------------------------------------------------------
clean_workspace()

# TODO --------------------------------------------------------------------
# Range plot --------------------------------------------------------------
# tax = 'Daphnia magna'
# cas_todo = dat[ taxon %in% tax, .N, cas][ order(-N) ][ , cas][1:50]
# dat2_agg = dat2[ taxon %in% tax & cas %in% cas_todo,
#                  .(n = .N,
#                    range = abs(Reduce(`-`, range(concentration)))),
#                  .(cas, cname, taxon, duration) ][ order(-range) ]
# dat2_agg[ , .N, cas]
# 
# ggplot(dat2_agg, aes(y = as.character(cas), x = as.character(duration), fill = log10(range))) +
#   geom_raster()
# 
# ggplot(df, aes(x, y, fill = z)) + geom_raster(hjust = 0, vjust = 0)
# 
# endpoint_ranges = function(dat = NULL, tax = 'Daphnia magna', ept = 'XX50', eff = 'Mortality',
#                            dur = 48, conc = 'ug/l',
#                            top = 20, n_min = 2, dodge = 0.7) {
#   # filter
#   dat2 = dat[ taxon == tax &
#                 endpoint == ept &
#                 effect == eff &
#                 duration %in% dur &
#                 concentration_unit == conc ]
#   # most CAS entries
#   cas_todo = dat2[ , .N, cas ][ order(-N) ][1:top][ , cas]
#   # aggregate
#   dat_agg = dat2[ cas %in% cas_todo,
#                   .(n = .N,
#                     range = abs(Reduce(`-`, range(concentration))),
#                     min = min(concentration, na.rm = TRUE),
#                     max = max(concentration, na.rm = TRUE)),
#                   .(cas, cname, taxon, duration) ][ order(-range) ]
#   # plot
#   gg = ggplot(dat_agg[ n >= n_min ],
#          aes(x = reorder(cname, range), col = as.factor(duration), group = as.factor(duration))) +
#     geom_linerange(aes(ymin = min, ymax = max),
#                    position = position_dodge(width = dodge)) +
#     geom_point(aes(y = min),
#                position = position_dodge(width = dodge),
#                size = 1) +
#     geom_point(aes(y = max),
#                position = position_dodge(width = dodge),
#                size = 1) +
#     geom_text(aes(y = max, label = n),
#               position = position_dodge(width = dodge),
#               hjust = -1, size = 3) +
#     scale_y_continuous(trans = log_trans(), breaks = base_breaks(),
#                        labels = prettyNum) +
#     coord_flip() +
#     labs(title = tax,
#          color = 'Test durations',
#          y = 'Range') +
#     theme(axis.title.y = element_blank())
#   
#   return(gg)
# }
# # CONTINUE HERE!!
# endpoint_ranges(dat = dat,
#                 tax = 'Culex quinquefasciatus',
#                 ept = 'XX50',
#                 eff = 'Mortality',
#                 dur = c(24,48,72,96),
#                 conc = 'ug/l')
# 
# endpoint_ranges(dat = dat,
#                 tax = 'Mus musculus',
#                 ept = 'XX50',
#                 eff = 'Mortality',
#                 dur = c(24,48,72,96),
#                 conc = 'ug/l')
# 
# 
# # Ridgeline plot ----------------------------------------------------------
# tax = c("Rattus norvegicus", "Oncorhynchus mykiss", "Daphnia magna", "", "Apis mellifera",
#         "Danio rerio", "Pimephales promelas", "Mus musculus", "Cyprinus carpio", 
#         "Lepomis macrochirus", "Anas platyrhynchos")
# 
# # TODO put in function
# dat2 = dat[ concentration_unit == 'ug/l' &
#               taxon %in% tax &
#               endpoint == 'XX50' &
#               effect == 'Mortality' &
#               duration %in% c(24,48,72,96) ]
# 
# tax = 'Daphnia magna'
# 
# cas_todo = dat2[ taxon == tax, .N, cas][ order(-N) ][ , cas][ 1:10 ]
# 
# 
# 
# ggplot(dat2[ cas %in% cas_todo & taxon == tax  ],
#        aes(y = cname, x = concentration, col = as.character(duration)), fill = NA) +
#   geom_density_ridges(
#     jittered_points = TRUE,
#     position = position_points_jitter(width = 0.05, height = 0),
#     point_shape = '|', point_size = 3, point_alpha = 1, alpha = 0,
#   ) +
#   #scale_x_log10(breaks = c) +
#   # scale_x_continuous(trans = 'log10',
#   #                    breaks = trans_breaks('log10', function(x) 10^x),
#   #                    labels = trans_format('log10', math_format(10^.x))) +
#   # scale_x_continuous() +
#   scale_x_continuous(trans = log_trans(), breaks = base_breaks(),
#                      labels = prettyNum) +
#   labs(title = tax)
# 
# ggplot(dat2[ cas %in% cas_todo & taxon == tax ],
#        aes(x = cname, y = concentration, fill = as.character(duration))) +
#   geom_rug() +
#   # geom_violin(position = position_dodge()) +
#   scale_y_continuous(trans = log_trans(), breaks = base_breaks(),
#                      labels = prettyNum) +
#   coord_flip()





