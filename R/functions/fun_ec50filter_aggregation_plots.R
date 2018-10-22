# function to plot data created by fun_ec50_filagg()

ec50_filagg_plot = function(dt_pl, yaxis = 'casnr', cutoff = 25) {
  
  # debuging
  # dt_pl = fread(file.path(tempdir(), 'out.csv')); cutoff = 25; yaxis = 'casnr'


  # preparation -------------------------------------------------------------
  setDT(dt_pl)
  dt_pl[ , casnr := as.character(casnr) ]
  # exclude info columns
  dt_pl = dt_pl[ , .SD, .SDcols =! grep('_n|info|vls|taxa', names(dt_pl), ignore.case = TRUE, value = TRUE)]
  
  # read whole data set
  dt_all_pl = read_feather(file.path(cache, 'dt.feather'))
  setDT(dt_all_pl)
  dt_all_pl[ , comp_type := 'test' ]
  dt_all_pl = dt_all_pl[ , .SD, .SDcols = c('casnr', 'comp_name', 'comp_type', 'ep_value')]
  
  cols = grep('md|mn|min|max', names(dt_pl), ignore.case = TRUE, value = TRUE)
  dt_m = melt(dt_pl, id.vars = 'casnr', measure.vars = c(cols))
  dt_m[dt_all_pl, `:=` (comp_name = i.comp_name,
                        comp_type = i.comp_type), on = 'casnr']

  # split
  dt_l = split(dt_m, dt_m$variable)
  
  # order + cutoff
  dt_l = lapply(dt_l, setorder, value)
  dt_l = lapply(dt_l, head, cutoff)

  # filter whole data.table
  # dt_all_pl = dt_all_pl[ casnr %in% dt_l[[1]]$casnr ]  
  
  # plot function -----------------------------------------------------------
  # x = dt_l; y = dt_all_pl # debug me!
  gg_ec50 = function(x, y = dt_all_pl, yaxis = c('casnr', 'comp_name')) {
    # prepare
    y = y[ casnr %in% x$casnr ]
    yaxis = match.arg(yaxis)
    
    gg_out = ggplot(x, aes(y = reorder(get(yaxis), -value), x = value)) + #, col = comp_type)) +
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
  

  # apply plot function -----------------------------------------------------
  gg_l = lapply(dt_l, gg_ec50, yaxis = yaxis)
  gg_out = plot_grid(plotlist = gg_l, ncol = 2)
  
  return(gg_out)
}









