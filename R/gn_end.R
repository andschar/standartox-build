# script to write final log entry and send an accomplishment mail

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))
dur = Sys.time() - readRDS('start_time')

# data --------------------------------------------------------------------
recip = 'scharmueller@uni-landau.de'
msg = paste('END: All scripts successfully run.',
            dur,
            sep = '\n')
fl = list.files(prj, pattern = 'script.log')

# mail --------------------------------------------------------------------
mailx(recip, sub = msg, attachment = fl)

# log ---------------------------------------------------------------------
log_msg(msg)

# cleaning ----------------------------------------------------------------
clean_workspace()