ec50_filagg_plot = function(dt_pl) {
  
  # out = fread('/tmp/out.csv')
  # dt_pl = out # debuging
  dt_pl = dt_pl[ , .SD, .SDcols =! grep('_n|info|vls|taxa', names(dt_pl), ignore.case = TRUE, value = TRUE)]
  
  dt_pl_m = melt(dt_pl, id.vars = 'casnr')
  
  gg_out = ggplot(dt_pl_m, aes(y = reorder(casnr, -value), x = value)) +
    geom_point() +
    facet_wrap( ~ variable, scales = 'free_x') +
    scale_x_log10() +
    labs(y = 'CASNR', x = expression(concentration~(log10)~µg/L)) +
    theme_bw()
    #theme(axis.text.x = element_text(angle = 45, hjust = 1))
  
  return(gg_out)
  
}