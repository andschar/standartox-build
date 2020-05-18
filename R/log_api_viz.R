# script to visulaise API access
# TODO log APP accesses + create a script like this
# TODO visualise in D3
# TODO ip loaction world map

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
api = fread(file.path(prj, 'app/log/api/request.log'))

# polishing ---------------------------------------------------------------
setnames(api, c('request_method', 'path_info'), c('method', 'endpoint')) # TODO cahnge this in file
api[ , date := as.Date(system_time) ]
api[ endpoint == '/filter/rds', endpoint := '/filter' ] # convert old endpoint name to new
api[ , ip := sub('@', '', str_extract(http_user_agent, '@[0-9.]+'), fixed = TRUE) ]

# prepare -----------------------------------------------------------------
api2 = api[ endpoint %in% c('/catalog', '/filter') ]
my_ips = c(uni_my_laptop = '139.14.52.4',
           uni_server = '139.14.20.252',
           poststrasse = '77.21')
api2_all = api2[, .N, .(date, endpoint) ]
api2_notme = api2[ -grep(paste0(my_ips, collapse = '|'), ip) ][, .N, .(date, endpoint) ]

# plot --------------------------------------------------------------------
ggplot(api2_all,
       aes(x = date, y = N, col = endpoint)) +
  geom_point() +
  geom_vline(xintercept = as.Date('2020-05-16')) +
  geom_text(aes(x = as.Date('2020-05-16'), label = "\nPaper", y = max(N) * 0.25),
            colour = "blue") +
  scale_y_log10()

# write -------------------------------------------------------------------
# NB for now not written to disk

