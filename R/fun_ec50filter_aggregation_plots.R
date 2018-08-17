ec50_filagg_plot = function(dt_pl) {
  
  # debuging
  # out = fread('/tmp/out.csv')
  # dt_pl = out
  ### end
  
  dt_pl = dt_pl[ , .SD, .SDcols =! grep('_n|info|vls|taxa', names(dt_pl), ignore.case = TRUE, value = TRUE)]
  
  dt_pl_m = melt(dt_pl, id.vars = 'casnr')
  
  gg_out = ggplot(dt_pl_m, aes(y = reorder(casnr, -value), x = value)) +
    geom_point() +
    facet_wrap( ~ variable, scales = 'free_x') +
    scale_x_log10() +
    labs(y = 'CASNR', x = expression(concentration~(log10)~µg/L)) +
    ggtitle('Include all values in grey in the back!!!!') +
    theme_bw()
  
  return(gg_out)
  
}