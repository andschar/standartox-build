# counter_l = readRDS(file.path(cache, 'dt_counter.rds'))
# 
# counter = rbindlist(counter_l)
# #setorder(counter, N)
# 
# gg_counter = ggplot(counter, aes(y = N, x = reorder(Variable, N))) +
#   geom_bar(stat = 'identity') +
#   coord_flip()
