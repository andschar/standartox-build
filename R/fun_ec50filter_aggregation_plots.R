# function to plot data created by fun_ec50_filagg()

ec50_filagg_plot = function(dt_pl, dt_all_pl, yaxis = 'casnr', cutoff = 25) {
  
  # debuging
  # dt_pl = fread(file.path(tempdir(), 'out.csv'))
  # dt_all_pl = tests_data
  # cutoff = 25
  ### end
  # preparation
  setDT(dt_pl)
  dt_pl[ , casnr := as.character(casnr) ]
  
  # exclude info columns
  dt_pl = dt_pl[ , .SD, .SDcols =! grep('_n|info|vls|taxa', names(dt_pl), ignore.case = TRUE, value = TRUE)]
  
  # order and limit data
  cols = grep('md|mn|min|max', names(dt_pl), ignore.case = TRUE, value = TRUE)
  dt_m = melt(dt_pl, id.vars = 'casnr', measure.vars = c(cols))
  
  # split
  dt_l = split(dt_m, dt_m$variable)
  
  # order
  dt_l = lapply(dt_l, setorder, 'value')
  dt_l = lapply(dt_l, head, cutoff)

  # plot function
  gg_ec50 = function(x, cutoff) {
    gg_out = ggplot(x, aes(y = reorder(casnr, -value), x = value)) +
      geom_point() +
      #scale_x_log10() +
      labs(y = 'CASNR', x = expression(EC50~concentration~µg/L)) +
      # ggtitle(paste0(cutoff, ' lowest EC50 values')) +
      theme_bw()
    
    return(gg_out)
  }
  
  gg_l = lapply(dt_l, gg_ec50, cutoff)
  gg_out = plot_grid(plotlist = gg_l)
  
  return(gg_out)
  
}
  


## old:
#dt_pl_m = melt(dt_pl, id.vars = 'casnr')

# gg_out = ggplot(dt_pl_m, aes(y = reorder(casnr, -value), x = value)) +
#   geom_point() +
#   facet_wrap( ~ variable, scales = 'free_x') +
#   scale_x_log10() +
#   labs(y = 'CASNR', x = expression(concentration~(log10)~µg/L)) +
#   theme_bw()


