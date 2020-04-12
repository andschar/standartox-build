# function that exports some meta informaiton
# NOTE this is not generic yet

export_stamp = function() {
  q = "SELECT 'date', current_date::text
       UNION ALL
       SELECT 'time', current_time::text
       UNION ALL
       SELECT 'mean_concentration', avg(concentration)::text
       FROM standartox.tests_fin
       UNION ALL
       SELECT 'mean_duration', avg(duration)::text
       FROM standartox.tests_fin;"
  stamp = read_query(user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
                     query = q)
  setnames(stamp, c('variable', 'value'))
  fwrite(stamp, file.path(exportdir, 'METASTAMP'))  
}
