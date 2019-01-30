



# setup -------------------------------------------------------------------
require(data.table)
require(plotly)
require(ggplot2)
require(cowplot)

# source ------------------------------------------------------------------
source(file.path(fundir, 'fun_outliers.R'))

# functions ---------------------------------------------------------------
# debuging (has to be turned on in fun_ec50filter_aggregation.R)
# dt_pl = fread(file.path(tempdir(), 'out.csv')); cutoff = 25; yaxis = 'casnr'

# fun_ec50filter_aggregation() data ---------------------------------------
filagg_prep = function(dt_pl,
                       cutoff = 25) {
  setDT(dt_pl)
  dt_pl[, casnr := as.character(casnr)]
  # exclude info columns
  dt_pl = dt_pl[, .SD, .SDcols = !grep('_n|info|vls|taxa',
                                       names(dt_pl),
                                       ignore.case = TRUE,
                                       value = TRUE)]
  
  # whole data --------------------------------------------------------------
  # read whole data set
  dt_all_pl = read_feather(file.path(cache, 'dt.feather'))
  setDT(dt_all_pl)
  # calculate outliers (as in fun_ec50filter_aggregation.R)
  dt_all_pl[,
            #outl := outliers::scores(value_fin, type = 'iqr', lim = 1.5), # DEPR
            outl := rm_outliers(value_fin, lim = 1.5, na.rm = TRUE),
            by = .(casnr, taxon, dur_fin)]
  dt_all_pl[, outl := ifelse(is.na(outl), TRUE, FALSE)]
  
  dt_all_pl[, comp_type := 'test']
  cols = c('casnr',
           'comp_name',
           'comp_type',
           'value_fin',
           'outl',
           'ref_num')
  dt_all_pl = dt_all_pl[, .SD, .SDcols = cols]
  
  cols = grep('md|mn|min|max',
              names(dt_pl),
              ignore.case = TRUE,
              value = TRUE)
  dt_m = melt(dt_pl, id.vars = 'casnr', measure.vars = c(cols))
  dt_m[dt_all_pl, `:=` (
    comp_name = i.comp_name,
    comp_type = i.comp_type,
    outl = i.outl,
    ref_num = i.ref_num
  ), on = 'casnr']
  # split
  l_dt = split(dt_m, dt_m$variable)
  
  # order + cutoff
  l_dt = lapply(l_dt, setorder, value)
  l_dt = lapply(l_dt, head, cutoff)
  
  out_l = list(l_dt = l_dt,
               dt_all = dt_all_pl)
  
  return(out_l)
}


filagg_gg = function(dt,
                     dt_all,
                     yaxis = c('casnr', 'comp_name'),
                     xaxis = c('limout', 'log')) {
  # prepare
  dt_all = dt_all[casnr %in% dt$casnr]
  yaxis = match.arg(yaxis)
  xaxis = match.arg(xaxis)
  
  gg_out = ggplot(dt, aes(y = reorder(get(yaxis), -value),
                          x = value)) + #, col = comp_type)) +
    geom_point(size = 0.001) + #! dummy to keep ordering. Change this at one point
    geom_point(
      data = dt_all,
      aes(
        y = get(yaxis),
        x = value_fin,
        col = outl
      ),
      shape = 1,
      size = 1.25
    ) +
    geom_point() +
    {
      if (xaxis == 'limout')
        coord_cartesian(xlim = range(dt$value))
    } +
    {
      if (xaxis == 'log')
        scale_x_log10()
    } +
    {
      if (yaxis == 'casnr')
        labs(y = 'CAS')
    } +
    {
      if (yaxis == 'comp_name')
        labs(y = 'Compound name')
    } +
    labs(x = 'Concentration (ug/L)') +
    #title = paste(l[[1]]$variable, 'EC50', 'values', sep = ' ')) +
    theme_bw2
  
  return(gg_out)
}

filagg_ly = function(dt,
                     dt_all,
                     yaxis = 'casnr',
                     xaxis = 'limout') {
  # prepare
  dt_all = dt_all[casnr %in% dt$casnr]
  
  yform = list(
    categoryorder = "array",
    categoryarray = dt[, get(yaxis)][order(dt$value, decreasing = TRUE)],
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
                 range = range(dt$value))
  }
  
  ly_out = plot_ly() %>%
    add_trace(
      data = dt_all,
      x = ~ value_fin,
      y = ~ get(yaxis),
      text = paste0('EPA Reference number: ', dt_all$ref_num),
      name = 'Test data',
      type = 'scatter',
      mode = 'markers',
      showlegend = FALSE,
      marker = list(size = 7,
                    color = 'rgba(255, 182, 193, .5)')
    ) %>%
    add_trace(
      data = dt,
      x = ~ value,
      y = ~ get(yaxis),
      text = paste0('EPA Reference number: ', dt$ref_num),
      name = paste0('Test data (', unique(dt$variable), ')'),
      type = 'scatter',
      mode = 'markers',
      showlegend = TRUE,
      marker = list(size = 5,
                    color = 'rgba(255, 182, 0)')
    ) %>%
    layout(title = paste0(dt$variable),
           yaxis = yform,
           xaxis = xform)
  
  # TODO: dsahboardbox should scale with plotly
  return(ly_out)
}

### DEBUGING
# 1
# filagg_pl(dt_pl,
#           plot_type = 'dynamic',
#           yaxis = 'comp_name',
#           xaxis = 'limout')
# # 2
# l = filagg_prep(dt_pl, 25)
# p = filagg_ly(l[[1]]$md, l[[2]], 'casnr', 'log')
# subplot(p, nrows = 1, which_layout = 1, titleX = TRUE)
### END

# apply plot function -----------------------------------------------------
filagg_pl = function(data,
                     plot_type = 'dynamic',
                     yaxis = 'casnr',
                     xaxis = 'limout',
                     cutoff = 25) {
  # prepare data
  l = filagg_prep(data, cutoff = cutoff)
  
  # gg or plotly data
  if (plot_type == 'dynamic') {
    pl_l = lapply(
      l[[1]],
      FUN = filagg_ly,
      dt_all = l[[2]],
      yaxis = yaxis,
      xaxis = xaxis
    )
    out = subplot(pl_l,
                  nrows = length(l[[1]]),
                  titleX = TRUE)
  }
  
  if (plot_type == 'static') {
    pl_l = lapply(
      l[[1]],
      FUN = filagg_gg,
      dt_all = l[[2]],
      yaxis = yaxis,
      xaxis = xaxis
    )
    out = plot_grid(plotlist = pl_l,
                    nrow = ceiling(length(l[[1]]) / 2))
  }
  
  return(out)
}
