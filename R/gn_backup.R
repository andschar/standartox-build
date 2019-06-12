# script to backup final data base

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# backup ------------------------------------------------------------------
cmd = sprintf("pg_dump -Fc -h %s -p %s %s > %s2.bak",
              DBhost, DBport, DBetox, DBetox) # -Fc reduces size by 90%
system(cmd)

# log ---------------------------------------------------------------------
log_msg('DATABASE BACKUP: run')

# cleaning ----------------------------------------------------------------
clean_workspace()