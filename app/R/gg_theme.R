# own ggplot theme

theme_bw2 = theme_bw(base_size = 12, base_family = 'Helvetica') +
  theme(#panel.grid.major = element_blank(),
        #panel.grid.minor = element_blank(),
        text = element_text(size = 14),
        axis.text = element_text(size = 12),
        axis.title.x = element_text(size = 14,face = 'bold', vjust = 0),
        axis.title.y = element_text(size = 14,face = 'bold', vjust = 1),
        legend.position = 'bottom',
        legend.key = element_blank(),
        strip.background = element_blank(),
        strip.text = element_text(size = 14, face = 'bold'))
