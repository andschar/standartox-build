# function to plot data created by fun_ec50_filagg()

ec50_filagg_plot = function(dt_pl, yaxis = 'casnr', cutoff = 25) {
  
  # debuging
  # dt_pl = fread(file.path(tempdir(), 'out.csv')); cutoff = 25; yaxis = 'casnr'
  ### end
  
  # preparation
  setDT(dt_pl)
  dt_pl[ , casnr := as.character(casnr) ]
  
  # exclude info columns
  dt_pl = dt_pl[ , .SD, .SDcols =! grep('_n|info|vls|taxa', names(dt_pl), ignore.case = TRUE, value = TRUE)]
  
  # order and limit data
  cols = grep('md|mn|min|max', names(dt_pl), ignore.case = TRUE, value = TRUE)
  dt_m = melt(dt_pl, id.vars = 'casnr', measure.vars = c(cols))
  dt_m[dt_all_pl, `:=` (comp_name = i.comp_name,
                        comp_type = i.comp_type), on = 'casnr']
  
  # split
  dt_l = split(dt_m, dt_m$variable)
  
  # order + cutoff
  dt_l = lapply(dt_l, setorder, 'value')
  dt_l = lapply(dt_l, head, cutoff)
  
  # whole data set
  dt_all_pl = readRDS(file.path(tempdir(), 'dt.rds')) # TODO incorporate this in aggregate function?
  dt_all_pl = dt_all_pl[ , .SD, .SDcols = c('casnr', 'comp_name', 'comp_type', 'ep_value')]
  dt_all_pl = dt_all_pl[ casnr %in% dt_l[[1]]$casnr ]
  #dt_all_pl = dt_all_pl[ casnr %in% dt_l[[2]]$casnr ]
  #dt_all_pl = dt_all_pl[ get(yaxis) %in% dt_l[[2]][ ,get(yaxis)] ]
  
  
  
  # plot function
  # x = dt_l; y = dt_all_pl # debug me!
  gg_ec50 = function(x, y = dt_all_pl, yaxis = c('casnr', 'comp_name')) {
    # prepare
    # x[ , x_yaxis := factor(x$yaxis, levels = order(yaxis, value))]; x[ get(yaxis) := NULL ]
    # y[ , y_yaxis := factor(get(yaxis), levels = order(get(yaxis), ep_value))]
    # x[]
    # setnames(x, old = 'x_yaxis', new = yaxis)
    # setnames(y, old = 'y_yaxis', new = yaxis)
    yaxis = match.arg(yaxis)
    
    gg_out = ggplot(x, aes(y = reorder(get(yaxis), -value), x = value)) + #, col = comp_type)) +
    #gg_out = ggplot(x, aes(y = reorder(get(yaxis), -value), x = value)) + #, col = comp_type)) +
      geom_point(size = 0.001) + # TODO dummy to keep ordering. Change this at one point
      geom_point(data = y, aes(y = get(yaxis), x = ep_value), col = 'gray', size = 0.75) + 
      geom_point() +
      #scale_x_log10() +
      coord_cartesian(xlim = range(x$value)) +
      labs(y = yaxis, x = expression(EC50~concentration~µg/L),
           title = paste(x$variable, 'EC50', 'values', sep = ' ')) +
      theme_bw2
    
    return(gg_out)
  }
  
  gg_l = lapply(dt_l, gg_ec50, yaxis = yaxis)
  gg_out = plot_grid(plotlist = gg_l, ncol = 2)
  
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


