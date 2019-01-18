# function to plot data created by fun_ec50_filagg()

# setup -------------------------------------------------------------------
require(data.table)

# source ------------------------------------------------------------------
source(file.path(fundir, 'fun_outliers.R'))

# function ----------------------------------------------------------------
ec50_filagg_plot = function(dt_pl,
                            yaxis = 'casnr',
                            xaxis = 'limout',
                            cutoff = 25,
                            ...) {
  
  # debuging (has to be turned on in fun_ec50filter_aggregation.R)
  # dt_pl = fread(file.path(tempdir(), 'out.csv')); cutoff = 25; yaxis = 'casnr'
  
  # fun_ec50filter_aggregation() data ---------------------------------------
  setDT(dt_pl)
  dt_pl[ , casnr := as.character(casnr) ]
  # exclude info columns
  dt_pl = dt_pl[ , .SD, .SDcols =! grep('_n|info|vls|taxa', names(dt_pl), ignore.case = TRUE, value = TRUE)]
  
  # whole data --------------------------------------------------------------
  # read whole data set
  dt_all_pl = read_feather(file.path(cache, 'dt.feather'))
  fwrite(dt_all_pl, '/tmp/dt_all_pl.csv')
  setDT(dt_all_pl)
  # calculate outliers (as in fun_ec50filter_aggregation.R)
  dt_all_pl[ ,
             #outl := outliers::scores(value_fin, type = 'iqr', lim = 1.5),
             outl := rm_outliers(value_fin, lim = 1.5, na.rm = TRUE),
             by = .(casnr, taxon, dur_fin) ]
  dt_all_pl[ , outl := ifelse(is.na(outl), TRUE, FALSE)]
  
  dt_all_pl[ , comp_type := 'test' ]
  cols = c('casnr', 'comp_name', 'comp_type', 'value_fin', 'outl', 'ref_num')
  dt_all_pl = dt_all_pl[ , .SD, .SDcols = cols]
  
  cols = grep('md|mn|min|max', names(dt_pl), ignore.case = TRUE, value = TRUE)
  dt_m = melt(dt_pl, id.vars = 'casnr', measure.vars = c(cols))
  dt_m[dt_all_pl, `:=` (comp_name = i.comp_name,
                        comp_type = i.comp_type,
                        ref_num = i.ref_num), on = 'casnr']
  fwrite(dt_m, '/tmp/dt_m.csv')
  # split
  dt_l = split(dt_m, dt_m$variable)
  
  # order + cutoff
  dt_l = lapply(dt_l, setorder, value)
  dt_l = lapply(dt_l, head, cutoff)

  # plot function -----------------------------------------------------------
  # x = dt_l; y = dt_all_pl # debug me!
  out_pl = function(dt_out,
                    dt_all = dt_all_pl,
                    yaxis = c('casnr', 'comp_name'),
                    xaxis = c('limout', 'log10'),
                    plot_type = 'static') {
    
    # prepare
    dt_all = dt_all[ casnr %in% dt_out$casnr ]
    yaxis = match.arg(yaxis)
    xaxis = match.arg(xaxis)
    
    gg_out = ggplot(dt_out, aes(y = reorder(get(yaxis), -value),
                                x = value)) + #, col = comp_type)) +
      geom_point(size = 0.001) + # TODO dummy to keep ordering. Change this at one point
      geom_point(data = dt_all, aes(y = get(yaxis),
                                    x = value_fin,
                                    col = outl), shape = 1, size = 1.25) + 
      geom_point() +
      { if (xaxis == 'limout') coord_cartesian(xlim = range(dt_out$value)) } +
      { if (xaxis == 'log10') scale_x_log10() } +
      { if (yaxis == 'casnr') labs(y = 'CAS') } +
      { if (yaxis == 'comp_name') labs(y = 'Compound name') } +
      labs(x = 'Concentration (ug/L)') +
           #title = paste(dt_out$variable, 'EC50', 'values', sep = ' ')) +
      theme_bw2
    
    ly_out = plot_ly(dt_m, x = ~value, y = ~casnr,
                     marker = list(size = 10,
                                   color = 'rgba(255, 182, 193, .9)'),
                     type = 'scatter',
                     mode = 'markers') %>% 
      add_trace(text = paste0('Ref. number: ', dt_m$ref_num),
                showlegend = FALSE) %>%
      layout(title = 'Styled Scatter',
             yaxis = list(zeroline = FALSE),
             xaxis = list(zeroline = FALSE,
                          type = 'log'))
    
    if (plot_type == 'static') {
      return(gg_out)
    }
    if (plot_type == 'dynamic') {
      return(ly_out)
    }
    
  }
  
  # apply plot function -----------------------------------------------------
  gg_l = lapply(dt_l, out_pl, yaxis = yaxis, xaxis = xaxis)
  gg_out = plot_grid(plotlist = gg_l, ncol = 2)
  
  return(gg_out)
}









