# script to plot the frequency of specific test parameters

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
# select columns programmatically
q = "SELECT column_name
     FROM information_schema.columns
     WHERE table_schema = 'standartox' AND table_name = 'data2'
     AND (column_name IN ('endpoint', 'effect', 'tax_order') OR
          column_name LIKE 'ccl_%' OR
          column_name LIKE 'hab_%' OR
          column_name LIKE 'reg_%')"
cols = read_query(user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
                  query = q)
# data
l = list()
for (i in seq_along(cols$column_name)) {
  
  col = cols$column_name[i]
  message('Fetching: ', col)
  q = paste0("SELECT ", col, ", count(*) n
              FROM standartox.data2
              GROUP BY ", col, " ",
             "ORDER BY n DESC")
  l[[i]] = read_query(user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
                      query = q)
  names(l)[i] = col
}

# prepare -----------------------------------------------------------------
l2 = list(endpoint = l$endpoint,
          effect = l$effect,
          ccl = na.omit(rbindlist(l[ grep('ccl_', names(l)) ], idcol = 'ccl', use.names = FALSE)),
          tax_order = l$tax_order,
          hab = na.omit(rbindlist(l[ grep('hab_', names(l)) ], idcol = 'hab', use.names = FALSE)),
          reg = na.omit(rbindlist(l[ grep('reg_', names(l)) ], idcol = 'reg', use.names = FALSE)))

l2$ccl$ccl = str_to_title(sub('ccl_', '', l2$ccl$ccl))
l2$hab$hab = str_to_title(sub('hab_', '', l2$hab$hab))
l2$reg$reg = str_to_title(sub('america_south', 'South America', sub('america_north', 'North America', (gsub('reg_', '', l2$reg$reg)))))

# plot --------------------------------------------------------------------
pl_l = list()
gg_l = list()
for (i in seq_along(l2)) {
  col = names(l2)[i]
  dat = l2[[i]]
  setorder(dat, -n)
  dat = na.omit(dat[1:20]) # NOTE limit x-axis
  # treemap
  pl_l[[i]] = treemap(dat, index = col, vSize = 'n')
  names(pl_l)[i] = col
  # ggplot
  # https://stackoverflow.com/questions/43999317/how-to-call-reorder-within-aes-string-of-ggplot
  gg_l[[i]] = ggplot(dat, aes_string(y = 'n', x = paste0('reorder(', col, ', -n)'))) +
    geom_bar(stat = 'identity') +
    theme(axis.text.x = element_text(angle = 45, hjust = 1),
          axis.title.x = element_blank(),
          axis.title.y = element_blank())
  names(gg_l)[i] = col
}

## cowplot
fin = cowplot::plot_grid(plotlist = gg_l, ncol = 2, labels = 'AUTO')

# write -------------------------------------------------------------------
ggsave(plot = fin, file.path(article, 'figures', 'standartox_parameters.png'),
       width = 10, height = 12)

# log ---------------------------------------------------------------------
log_msg('ARTICLE: Standartox data overview ploted')

# cleaning ----------------------------------------------------------------
clean_workspace()






































