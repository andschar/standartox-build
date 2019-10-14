# function to clean all but some variables
# https://stackoverflow.com/questions/54790498/function-to-clean-current-workspace-apart-from-some-variables/54790728#54790728

clean_workspace <- function(not_to_be_removed, envir = .GlobalEnv) {
  
  not_to_be_removed = c('prj', 'src', 'nodename', 'DBetox', 'time', 'mdl',
                        'download_db',
                        'build_db',
                        'download',
                        'build_standartox',
                        'build_norman',
                        'build',
                        'debug_mode',
                        'sink_console',
                        'general',
                        'log_msg')
  
  rm(list = setdiff(
    ls(envir = envir),
    c("clean_workspace", not_to_be_removed)
  ),
  envir = envir)
  gc()
}
