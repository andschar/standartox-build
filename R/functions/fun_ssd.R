# SSD function script 
# https://github.com/bcgov/ssdtools

### debuging
# dt = data.table(ssdtools::boron_data) # debug me!
# names(dt)
# setnames(dt, paste0(names(dt), 1:5))
### end

fun_ssd = function(dt) {
  
  dt_dists = ssd_fit_dists(dt)#, left = 'Conc3')
  # dt_hc5 = ssd_hc(dt_dists, nboot = 10000)
  dt_predict = predict(dt_dists)
  
  ssd_pl = ssd_plot(dt, dt_predict, shape = 'Group', label = 'Species',
                    xlab = "Concentration (mg/L)", ribbon = TRUE) + 
    expand_limits(x = 3000)
  
  # ssd_gof(dt_dists)
  # autoplot(dt_dists)
  # out_l = list()
  # out_l[['plot']] == ssd_pl
  # out_l[['hc5']] == dt_hc5
  
  return(ssd_pl)
}

# test1 = fun_ssd(dt)
