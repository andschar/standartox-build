# functions to build sql queries


# chemical names ----------------------------------------------------------
# function(dat, ) {
#   
#   dat$column_name_full = with(dat, paste0(table_name, '.', column_name))
#   
#   select = 
#   
#   
#   
# }



# chemical class flags ----------------------------------------------------
# find the greatest (0,1) value of multiple columns in muktiple tables joined together by one key column

# debug
# dat = dt
# main_tbl = 'epa'
# main_sch = 'phch'
# col_join = 'cas'

q_join = function(dat, schema, main_tbl, col_join, fun, debug = TRUE) {
  
  # checks
  if (is.null(fun))
    stop('No function defined.')
  
  # column name (table.column)
  dat$column_name_full = with(dat, paste0(table_name, '.', column_name))
  
  # main and join tables
  #dat0 = dat[ grep(main, table_name) ]
  #dat1 = dat[ -grep(main, table_name) ]
  # join table names
  tbl = unique(dat$table_name)
  tbl = grep(paste0('^', main_tbl, '$'), tbl, invert = TRUE, value = TRUE)
  # column names
  dat1 = split(dat, dat$column_name)
  col = lapply(dat1, `[[`, 'column_name')
  col_full = lapply(dat1, `[[`, 'column_name_full')
  
  ## query builder
  select = paste0(
    "SELECT ",
    paste0(main_tbl, ".", col_join), ", ",
    paste0(
      paste0(
        paste0(fun, '('),
        lapply(col_full, paste0, collapse = ', '),
        ') AS ',
        lapply(col, function(x) paste0(unique(x), collapse = ', '))), 
      collapse = ', '
    )
  )
  from = paste0(
    "FROM ",
    paste0(schema, ".", main_tbl)
  )
  join = paste0(
    paste0(
      "LEFT JOIN ",
      paste0(schema, ".", tbl), " ON ",
      paste0(main_tbl, ".", col_join, " = "), tbl, ".", col_join),
    collapse = ' '
  )
  
  # dbeug
  if (debug) {
    q = paste(select, from, join, "LIMIT 10")
  } else {
    q = paste(select, from, join)
  }
  
  return(q)
}
