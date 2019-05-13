# script to write final log entry and send an accomplishment mail

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# data --------------------------------------------------------------------
crd = read.csv(file.path(cred, 'mail.csv'),
               stringsAsFactors = FALSE)

# mail --------------------------------------------------------------------
# via swaks
recip = crd$recipient
subj = 'Pipline finished'
msg = subj
user = crd$sender
pw = crd$pw
attach = c('console.log', 'script.log')

swaks_mail(recip, subj, msg, user, pw, attach)

# log ---------------------------------------------------------------------
log_msg('END: All scripts successfully run.')

# cleaning ----------------------------------------------------------------
clean_workspace()