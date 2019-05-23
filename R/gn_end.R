# script to write final log entry and send an accomplishment mail

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
recip = 'scharmueller@uni-landau.de'
msg = 'END: All scripts successfully run.'
fl = list.files(pattern = 'script.log')

# mail --------------------------------------------------------------------
mailx(recip, sub = msg, attachment = fl)

# log ---------------------------------------------------------------------
log_msg(msg)

# cleaning ----------------------------------------------------------------
clean_workspace()