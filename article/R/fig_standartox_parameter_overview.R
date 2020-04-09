# script to plot the frequency of specific test parameters

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
# select columns programmatically
q = "SELECT table_schema, table_name, column_name
     FROM information_schema.columns
     WHERE table_schema = 'standartox'
       AND table_name IN ('tests', 'chemicals', 'taxa')"
cols = read_query(user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
                  query = q)
pattern = c('effect', 'tax_order', 'cro_', 'ccl_', 'hab_', 'reg_')

cols = cols[ grep(paste0(pattern, collapse = '|'), column_name) ]

# data
l = list()
for (i in seq_along(cols$column_name)) {
  schema = cols$table_schema[i]
  tbl = cols$table_name[i]
  col = cols$column_name[i]
  message('Fetching: ', col)
  q = paste0("SELECT ", col, ", count(*) n
              FROM ", paste0(schema, '.', tbl), " ",
             "GROUP BY ", col, " ",
             "ORDER BY n DESC")
  l[[i]] = read_query(user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
                      query = q)
  names(l)[i] = col
}

# prepare -----------------------------------------------------------------
l2 = list(effect = l$effect,
          cro = na.omit(rbindlist(l[ grep('cro_', names(l)) ], idcol = 'cro', use.names = FALSE)),
          ccl = na.omit(rbindlist(l[ grep('ccl_', names(l)) ], idcol = 'ccl', use.names = FALSE)),
          tax_order = l$tax_order,
          hab = na.omit(rbindlist(l[ grep('hab_', names(l)) ], idcol = 'hab', use.names = FALSE)),
          reg = na.omit(rbindlist(l[ grep('reg_', names(l)) ], idcol = 'reg', use.names = FALSE)))
# TODO resolve in original data set (make to NA)
l2$tax_order = l2$tax_order[ l2$tax_order$tax_order != '' ]
l2$cro$cro = str_to_title(gsub('_', ' ',
                               sub('cro_', '', l2$cro$cro)))
l2$ccl$ccl = str_to_title(sub('ccl_', '', l2$ccl$ccl))
l2$hab$hab = str_to_title(sub('hab_', '', l2$hab$hab))
l2$reg$reg = str_to_title(sub('america_south', 'South America',
                              sub('america_north', 'North America',
                                  gsub('reg_', '', l2$reg$reg))))

# plot --------------------------------------------------------------------
tr_l = list()
gg_l = list()
for (i in seq_along(l2)) {
  col = names(l2)[i]
  dat = copy(l2[[i]])
  setorder(dat, -n)
  dat = na.omit(dat[1:15])
  # treemap
  tr_l[[i]] = ggplot(dat, aes_string(area = 'n',
                                     fill = col,
                                     label = col)) +
    geom_treemap() +
    geom_treemap_text(fontface = 'italic',
                      colour = 'white',
                      place = 'centre',
                      grow = FALSE,
                      reflow = TRUE) +
    scale_fill_viridis_d() +
    theme(legend.position = 'none')
  names(tr_l)[i] = col
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
gg_fin = cowplot::plot_grid(plotlist = gg_l, ncol = 2, labels = 'AUTO')
tr_fin = cowplot::plot_grid(plotlist = tr_l, ncol = 2, labels = 'AUTO')

# write -------------------------------------------------------------------
ggsave(plot = tr_fin, file.path(article, 'figures', 'standartox_parameters.png'),
       width = 10, height = 12)

# log ---------------------------------------------------------------------
log_msg('ARTICLE: Standartox data overview ploted.')

# cleaning ----------------------------------------------------------------
clean_workspace()






