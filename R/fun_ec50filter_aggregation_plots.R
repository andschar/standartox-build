# function to plot data created by fun_ec50_filagg()

ec50_filagg_plot = function(dt_pl, yaxis = 'casnr', cutoff = 25) {
  
  # debuging
  # dt_pl = fread(file.path(tempdir(), 'out.csv'))
  # dt_all_pl = tests_data
  # cutoff = 25
  ### end
  
  # data
  dt_all_pl = readRDS(file.path(tempdir(), 'dt.rds')) # TODO incorporate this in aggregate function?
  
  # preparation
  setDT(dt_pl)
  dt_pl[ , casnr := as.character(casnr) ]
  
  # exclude info columns
  dt_pl = dt_pl[ , .SD, .SDcols =! grep('_n|info|vls|taxa', names(dt_pl), ignore.case = TRUE, value = TRUE)]
  
  # order and limit data
  cols = grep('md|mn|min|max', names(dt_pl), ignore.case = TRUE, value = TRUE)
  dt_m = melt(dt_pl, id.vars = 'casnr', measure.vars = c(cols))
  dt_m[dt_all_pl, comp_name := i.comp_name, on = 'casnr']
  
  # split
  dt_l = split(dt_m, dt_m$variable)
  
  # order
  dt_l = lapply(dt_l, setorder, 'value')
  dt_l = lapply(dt_l, head, cutoff)

  # dt_l = lapply(dt_l, function(x) merge(x, dt_all_pl, by = 'casnr')) # like this?
  
  # plot function
  gg_ec50 = function(x, yaxis = 'casnr', cutoff) {
    gg_out = ggplot(x, aes(y = reorder(get(yaxis), -value), x = value)) +
      geom_point() +
      # geom_point(data = y, aes(y = casnr, x = ep_value), col = 'gray', size = 0.5) +
      # scale_x_log10() +
      labs(y = 'CASNR', x = expression(EC50~concentration~µg/L),
           title = paste(x$variable, 'EC50', 'values', sep = ' ')) +
      theme_bw2
    
    return(gg_out)
  }
  
  # gg_ec50(dt_l$min, yaxis = 'comp_name', cutoff = 25) debug me!
  gg_l = lapply(dt_l, gg_ec50, yaxis = yaxis, cutoff = cutoff)
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


