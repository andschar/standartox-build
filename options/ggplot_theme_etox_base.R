# ggplot themes

theme_bw_etox_base <- theme_bw(base_size = 12, base_family = 'Helvetica') +
  theme(#panel.grid.major = element_blank(),
        #panel.grid.minor = element_blank(),
        text = element_text(size = 14),
        axis.text = element_text(size = 13),
        axis.title.x = element_text(size = 14, face = 'bold', vjust = 0),
        axis.title.y = element_text(size = 14, face = 'bold', vjust = 1),
        legend.position = 'right',
        legend.key = element_blank(),
        strip.background = element_blank(),
        strip.text = element_text(size = 14, face = 'bold'))

theme_minimal_etox_base_sans <- theme_minimal(base_size = 12, base_family = 'Open Sans') +
  theme(#panel.grid.major = element_blank(),
        #panel.grid.minor = element_blank(),
        text = element_text(size = 14),
        axis.text = element_text(size = 15),
        axis.title.x = element_text(size = 14, face = 'bold', vjust = 0),
        axis.title.y = element_text(size = 14, face = 'bold', vjust = 1),
        legend.position = 'right',
        legend.key = element_blank(),
        strip.background = element_blank(),
        strip.text = element_text(size = 14, face = 'bold'))

