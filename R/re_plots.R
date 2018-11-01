# script to plot important test parameters

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# data --------------------------------------------------------------------
te_fin = readRDS(file.path(cachedir, 'tests_fin.rds'))

#  plot function ----------------------------------------------------------
etox_dur_plot = function(dt, tax, limit = 100) {
  
  # filter by tax groups
  cols_tax = grep('tax', names(dt), value = TRUE)
  dt2 = dt[dt[ , Reduce(`|`, lapply(.SD, `%like%`, paste0('(?i)', tax))), .SDcols = cols_tax ]]
  
  if (nrow(dt) == 0) {
    stop('Taxon not found.')
  }
  
  # calculate number of tests with respective group
  dt3 = dt2[ , .N, dur_fin]
  dt3[ , limit_col := ifelse(N < limit, 'below', 'above') ]
  
  # plot
  out = ggplot(dt3, aes(y = N, x = dur_fin, col = limit_col, label = dur_fin)) +
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

# plots -------------------------------------------------------------------
# todo vectors
todo_algae = c('Plants', 'Algae', 'Chlorophyceae', 'Cyanophyceae', 'Coscinodiscophyceae', 'Bacillariophyceae', 'Fungi')
todo_invertebrates = c('Insecta', 'Daphniidae', 'Invertebrates', 'Crustacea', 'Mollusca')
todo_other = c('Fish', 'Amphibia')
# list them
todo_l = list(todo_algae, todo_invertebrates, todo_other)

# create final plot list
pl_l = lapply(todo_l, function(todo) {
  dur_pl_l = mapply(etox_dur_plot, tax = todo,
                    MoreArgs = list(dt = te_fin,
                                    limit = 100),
                    SIMPLIFY = FALSE)
  dur_pl_cow = plot_grid(plotlist = dur_pl_l,
                         ncol = 2)
  
  return(dur_pl_cow)
})
names(pl_l) = sapply(todo_l, `[`, 1)

# writing -----------------------------------------------------------------
for (i in seq_along(pl_l)) {
  tax_grp = names(pl_l)[i]
  message('Saving ', tax_grp, ' plot')
  ggsave(pl_l[[i]], width = 8, height = 9,
         filename = file.path(plotdir, paste0(tax_grp, '_duration_plot.png')))
}

# cleaning ----------------------------------------------------------------
rm(todo_l, todo_algae, todo_invertebrates,
   pl_l, tax_grp)




