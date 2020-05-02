# script to visualize variability in ecotoxicological test data
# NOTE other dwellings at the end

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
if (download) {
  q = "SELECT result_id, casnr, cname,
              tax_taxon taxon, concentration,
              concentration_unit, duration, duration_unit,
              endpoint, effect, exposure
       FROM standartox.tests_fin
       LEFT JOIN standartox.phch USING (casnr)
       LEFT JOIN standartox.taxa USING (species_number)
       WHERE duration_unit = 'h'"
  
  dat = read_query(user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
                   query = q)
  saveRDS(dat, file.path(cachedir, 'fig_results_variability.rds'))
} else {
  
  dat = readRDS(file.path(cachedir, 'fig_results_variability.rds'))
}

# erros -------------------------------------------------------------------
# TODO fix this before
dat[ taxon == 'Pseudokirchneriella subcapitata', taxon := 'Raphidocelis subcapitata' ]
# TODO fix enopous error

# prepare -----------------------------------------------------------------
dat2 = dat[ taxon %in% c('Raphidocelis subcapitata', 'Lemna minor', 'Oncorhynchus mykiss', 'Rattus norvegicus', 'Xenopus laevis', 'enopus laevis', 'Daphnia magna', 'Pimephales promelas') &
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
              exposure == 'aquatic' &
              !taxon %in% c('Daphnia magna', 'Pimephales promelas') ]
tax[ taxon == 'Raphidocelis subcapitata', taxon := 'R. subcapitata' ] %>% 
  .[ taxon == 'Lemna minor', taxon := 'L. minor' ] %>% 
  .[ taxon == 'Oncorhynchus mykiss', taxon := 'O. mykiss' ] %>% 
  .[ taxon %in% c('Xenopus laevis', 'enopus laevis'), taxon := 'X. laevis' ]

tax_gm = tax[ ,
              .(min = min(concentration),
                gm = gm_mean(concentration),
                gmsd = EnvStats::geoSD(concentration),
                max = max(concentration)),
              .(taxon) ]

gg_tax = ggplot(tax, aes(x = taxon, y = concentration)) +
  geom_point(position = position_jitter(seed = 1234)) +
  geom_violin(position = position_dodge(), alpha = 0.5) +
  geom_errorbar(data = tax_gm, aes(x = taxon, y = gm, ymin = gm - gmsd, ymax = gm + gmsd),
                size = 1, col = 'red', alpha = 0.5) +
  geom_point(data = tax_gm, aes(x = taxon, y = gm), size = 3, col = 'red') +
  geom_point(data = tax_gm, aes(x = taxon, y = min), size = 1.5, col = 'black') +
  geom_point(data = tax_gm, aes(x = taxon, y = max), size = 1.5, col = 'black') +
  scale_y_log10(breaks = c(10, 100, 1000, 10000),
                labels = c(10, 100, 1000, 10000),
                limits = c(1, 100000)) +
  coord_flip() +
  theme(axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text.y = element_text(face = 'italic'))

# variability due to test duration ----------------------------------------
dur = dat2[ taxon == 'Daphnia magna' &
              casnr == '7733020' &
              effect %in% c('Mortality', 'Intoxication') &
              exposure == 'aquatic' ] # zinc sulfate
dur_gm = dur[ ,
              .(min = min(concentration),
                gm = gm_mean(concentration),
                gmsd = EnvStats::geoSD(concentration), # TODO replace with own function and in package
                am = mean(concentration),
                amsd = sd(concentration),
                max = max(concentration)),
              .(taxon, duration) ]

gg_dur = ggplot(dur, aes(x = duration, y = concentration)) +
  geom_point(position = position_jitter(seed = 1234)) +
  geom_violin(position = position_dodge(), alpha = 0.5) +
  geom_errorbar(data = dur_gm, aes(x = duration, y = gm, ymin = gm - gmsd, ymax = gm + gmsd),
                size = 1, col = 'red', alpha = 0.5) +
  geom_point(data = dur_gm, aes(x = duration, y = am), size = 3, col = 'blue') +
  geom_errorbar(data = dur_gm, aes(x = duration, y = am, ymin = am - amsd, ymax = am + amsd),
                size = 1, col = 'blue', alpha = 0.5) +
  geom_point(data = dur_gm, aes(x = duration, y = gm), size = 3, col = 'red') +
  geom_point(data = dur_gm, aes(x = duration, y = min), size = 1.5, col = 'black') +
  geom_point(data = dur_gm, aes(x = duration, y = max), size = 1.5, col = 'black') +
  scale_y_log10(breaks = c(10, 100, 1000, 10000),
                labels = c(10, 100, 1000, 10000),
                limits = c(1, 100000)) +
  coord_flip() +
  theme(axis.title.x = element_blank(),
        axis.title.y = element_blank())

# variability due to different laboratories -------------------------------
lab = dat2[ effect == 'Mortality' &
              exposure == 'aquatic' &
              casnr == '7758987' & # cupric sulfate
              taxon == 'Pimephales promelas' &
              duration == 96 ] # most tests
lab[ , cname := '  ' ] # HACK
lab_gm = lab[ ,
              .(min = min(concentration),
                gm = gm_mean(concentration),
                gmsd = EnvStats::geoSD(concentration),
                max = max(concentration)),
              .(taxon, cname) ]

gg_lab = ggplot(lab, aes(x = cname, y = concentration)) +
  geom_point(position = position_jitter(seed = 1234)) +
  geom_violin(position = position_dodge(), alpha = 0.5) +
  geom_errorbar(data = lab_gm, aes(x = cname, y = gm, ymin = gm - gmsd, ymax = gm + gmsd),
                size = 1, col = 'red', alpha = 0.5) +
  geom_point(data = lab_gm, aes(x = cname, y = gm), size = 3, col = 'red') +
  geom_point(data = lab_gm, aes(x = cname, y = min), size = 1.5, col = 'black') +
  geom_point(data = lab_gm, aes(x = cname, y = max), size = 1.5, col = 'black') +
  scale_y_log10(breaks = c(10, 100, 1000, 10000),
                labels = c(10, 100, 1000, 10000),
                limits = c(1, 100000)) +
  coord_flip() +
  theme(axis.title.x = element_blank(),
        axis.text.x = element_text(),
        axis.title.y = element_blank())

# combine variability plots -----------------------------------------------
left = plot_grid(gg_tax,
                 ncol = 1, labels = 'AUTO')
right = plot_grid(gg_dur, gg_lab,
                  nrow = 2,
                  labels = c('B', 'C'),
                  align = 'v')
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
