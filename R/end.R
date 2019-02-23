# script to write final log entry and send an accomplishment mail

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# mail --------------------------------------------------------------------
# TODO implement!

# log ---------------------------------------------------------------------
msg = 'END: All scripts successfully run.'
log_msg(msg)

# cleaning ----------------------------------------------------------------
clean_workspace()