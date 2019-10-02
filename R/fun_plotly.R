# function to create plot for application

plotly_prep = function(agg,
                       fil,
                       cutoff = 25) {
  ## prepartaion
  setDT(agg)
  agg[ , cas := as.character(cas) ]
  setDT(fil)
  fil[ , cas := as.character(cas) ]
  ## aggregated data
  cols = grep('gm|md|mn|min|max',
              names(agg),
              ignore.case = TRUE,
              value = TRUE)
  agg_m = melt(agg, id.vars = 'cas', measure.vars = cols)
  agg_m[fil, `:=` (
    cname = i.cname
    # TODO outl = i.outl,
    # TODO ref_num = i.ref_num
  ), on = 'cas']
  # split (in case of multiple variables)
  l_agg = split(agg_m, agg_m$variable)
  # order + cutoff
  l_agg = lapply(l_agg, setorder, value)
  l_agg = lapply(l_agg, head, cutoff)
  ## filtered data
  col_fil = c('cas', 'cname', 'concentration')
  fil2 = fil[ , .SD, .SDcols = col_fil ]
  fil2 = fil2[ cas %in% agg$cas ]
  fil2[ ,
        outl := rm_outliers(concentration, lim = 1.5, na.rm = TRUE),
        by = cas ]
  fil2[ , outl := ifelse(is.na(outl), TRUE, FALSE)]
  
  ## return
  out_l = list(l_agg = l_agg,
               fil2 = fil2)
  
  return(out_l)
}
  
plotly_plot = function(agg,
                       fil,
                       yaxis = 'cas',
                       xaxis = 'limout') {
  ## preparation
  fil2 = fil[ cas %in% agg$cas ]
  ## axis
  yform = list(
    categoryorder = "array",
    categoryarray = agg[ order(value, decreasing = TRUE) ][ , get(yaxis) ],
    type = 'category',
    nticks = 1000
  ) #! dummy to plot all y entries
  if (xaxis == 'log') {
    xform = list(title = 'Concentration (ug/L)',
                 zeroline = FALSE,
                 type = 'log')
  }
  if (xaxis == 'limout') {
    xform = list(title = 'Concentration (ug/L)',
                 zeroline = FALSE,
                 range = range(agg$value))
  }
  ## plot
  out = plot_ly() %>% 
    add_trace(
      data = fil2,
      x = ~ concentration,
      y = ~ get(yaxis),
      # TODO text = paste0('EPA Reference number: ', fil2$ref_num),
      name = 'Test data',
      type = 'scatter',
      mode = 'markers',
      showlegend = FALSE,
      marker = list(size = 7,
                    color = 'rgba(255, 182, 193, .5)')
    ) %>%
    add_trace(
      data = agg,
      x = ~ value,
      y = ~ get(yaxis),
      # TODO text = paste0('EPA Reference number: ', fil2$ref_num),
      # TODO name = paste0('Test data (', unique(agg$variable), ')'),
      type = 'scatter',
      mode = 'markers',
      showlegend = TRUE,
      marker = list(size = 5,
                    color = 'rgba(255, 182, 0)')
    ) %>%
    layout(title = paste0(agg$variable),
           yaxis = yform,
           xaxis = xform)
  
  return(out)
}

plotly_fin = function(agg,
                      fil,
                      yaxis = 'cas',
                      xaxis = 'limout',
                      cutoff = 25) {
  ## prepare data
  l = plotly_prep(agg = agg, fil = fil, cutoff = cutoff)
  ## plotly data
  pl_l = lapply(
    l[[1]],
    FUN = plotly_plot,
    fil = l[[2]],
    yaxis = yaxis,
    xaxis = xaxis
  )
  out = subplot(pl_l,
                nrows = length(l[[1]]),
                titleX = TRUE)
  
    return(out) 
}

# debuging ----------------------------------------------------------------
# fil = fread('/home/scharmueller/Downloads/_2448_data_fil.csv')
# agg = fread('/home/scharmueller/Downloads/_2448_data_agg.csv')
# yaxis = 'cas'
# 
# plotly_fin(agg = agg,
#            fil = fil,
#            yaxis = 'cas',
#            xaxis = 'limout',
#            cutoff = 40)








