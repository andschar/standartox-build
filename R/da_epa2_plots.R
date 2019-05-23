# plot test number of tests per durations

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))
source(file.path(src, 'fun_duration_plots.R'))

# data --------------------------------------------------------------------
epa2 = readRDS(file.path(cachedir, 'epa2.rds'))
epa2 = epa2[ obs_duration_unit_conv == 'h' ]

# plots -------------------------------------------------------------------
# todo vectors
todo_pl_al = c('Plants', 'Algae')
todo_makroph = c('Lemna', 'Myriophyllum')
todo_micro = c('Chlorophyceae', 'Cyanophyceae', 'Coscinodiscophyceae', 'Bacillariophyceae', 'Fungi')
todo_invertebrates = c('Insecta', 'Daphniidae', 'Invertebrates', 'Crustacea', 'Mollusca')
todo_other = c('Fish', 'Amphibia')
# list them
todo_l = list(todo_pl_al, todo_makroph, todo_micro, todo_invertebrates, todo_other)

# create final plot list
pl_l = lapply(todo_l, function(todo) {
  dur_pl_l = mapply(etox_dur_plot, tax = todo,
                    MoreArgs = list(dt = epa2,
                                    dur = 'obs_duration_mean',
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




