# plot N of individual test duration by taxon

etox_dur_plot = function(dt, tax, dur, limit = 100) {
  
  # filter by tax groups
  cols_tax = grep('tax', names(dt), value = TRUE)
  dt2 = dt[dt[ , Reduce(`|`, lapply(.SD, `%like%`, paste0('(?i)', tax))), .SDcols = cols_tax ]]
  
  if (nrow(dt) == 0) {
    stop('Taxon not found.')
  }
  
  # calculate number of tests with respective group
  dt3 = dt2[ , .N, dur]
  dt3[ , limit_col := ifelse(N < limit, 'below', 'above') ]
  
  # plot
  out = ggplot(dt3, aes(y = N, x = get(dur), col = limit_col, label = get(dur))) +
    geom_text() +
    scale_color_manual(values = c('black', 'grey')) +
    scale_y_log10() +
    scale_x_log10() +
    geom_hline(yintercept = limit, col = 'orange', lty = 'dashed') +
    labs(title = paste0(tax, ' tests'),
         x = 'duration (h)') +
    theme(axis.title.y = element_text(angle = 180)) +
    theme(legend.position = 'none')

  return(out)
}



