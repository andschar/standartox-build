#!/usr/bin/Rscript

# this is the main script that has to be sourced and timed on the platform
# time this script tp run every 2 months
# crontab:
# 00 22 * * * /home/scharmueller/Projects/run_build.sh

# projects directory -------------------------------------------------------
## find folder name on system - slow, but generic!
# prj = system("find / -name etox-base 2>/dev/null", intern = TRUE)[1] # locate prj dir
# shinydir = system("find / -name etox-base-shiny 2>/dev/null", intern = TRUE)[1] # locate shiny dir
## pre-defined
nodename = Sys.info()[4]
if (nodename == 'scharmueller') {
  prj = '/home/andreas/Documents/Projects/etox-base'
  shinydir = '/home/andreas/Documents/Projects/etox-base-shiny'
} else if (nodename == 'uwigis') {
  prj = '/home/scharmueller/Projects/etox-base'
  shinydir = '/home/scharmueller/Projects/etox-base-shiny'
} else {
  stop('New system. Define prj and shinydir variables.')
}

# (0) setup ---------------------------------------------------------------
source(file.path(prj, 'R/setup.R'), max.deparse.length = 1e6)


# (0a) console log ---------------------------------------------------------
if (nodename == 'uwigis') {
  con = file(file.path(prj, 'console.log'))
  sink(con, append = TRUE)
  sink(con, append = TRUE, type = 'message')
}

# (1) build data base -----------------------------------------------------
# download
source(file.path(src, 'bd_epa_download.R'), max.deparse.length = 1e6)
# build
source(file.path(src, 'bd_epa_postgres.R'), max.deparse.length = 1e6)


# (2) queries + data preparation ------------------------------------------
source(file.path(src, 're_merge.R'), max.deparse.length = 1e6)
source(file.path(src, 're_combine.R'), max.deparse.length = 1e6)
source(file.path(src, 're_checks.R'), max.deparse.length = 1e6)


# (3) final table ---------------------------------------------------------
source(file.path(src, 're_final.R'), max.deparse.length = 1e6)


# (4) scripts base on final table -----------------------------------------
## write
# write to database and save as .rds (also to shinydir)
source(file.path(src, 're_write.R'), max.deparse.length = 1e6)
## meta table
source(file.path(src, 're_meta.R'), max.deparse.length = 1e6)
## stats table
source(file.path(src, 're_stats.R'), max.deparse.length = 1e6)
## shiny variables
source(file.path(src, 're_shiny_variables.R'), max.deparse.length = 1e6)
## plots
# TODO NOT WORKING YET
# source(file.path(src, 're_plots.R'), max.deparse.length = 1e6)



# # (0b) console log 2 --------------------------------------------------------
if (nodename == 'uwigis') {
  # Restore output to console
  sink()
  sink(type="message")
}








