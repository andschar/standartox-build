# script to calculate publishing (i.e. adding of new test results) rate

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
q = "SELECT published_date, count(*) n 
     FROM ecotox.tests
     GROUP BY published_date
     ORDER BY n desc"

dat = read_query(user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
                 query = q)

# prepare -----------------------------------------------------------------
dat[ , published_date := as.Date(published_date, format = '%m/%d/%Y') ]
setorder(dat, -published_date)
dat = na.omit(dat)
dat14 = dat[ published_date %between% c('2014-01-01', '2019-12-31') ]

vl = paste0(round(mean(dat14$n)), '\rpm', round(sd(dat14$n)))

# write -------------------------------------------------------------------
writeLines(vl, file.path(article, 'values', 'publish_rate.txt'))

# log ---------------------------------------------------------------------
log_msg('ARTICLE: VALUES: publish rate.')

# cleaning ----------------------------------------------------------------
clean_workspace()
