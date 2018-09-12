
# 
# system(
#   'gksudo apt-get update
#    gksudo apt-get install postgresql postgresql-contrib',
#   intern = FALSE
# )
# 
# system(
#   'unzip'
# )
# 


##! sourced from DB_access-script
# DBnameL <- 'epa_ecotox'
# DBhostL <- 'localhost' # 127.0.0.1
# DBportL <- '5432'
# DBuserL <- 'epa_ecotox'
# DBpasswordL <- 'epaecotox'

##! If password leads to connection problems:
##! sudo -u user_name psql db_name
##! ALTER USER user_name WITH PASSWORD 'new_password';already included above.
##! http://stackoverflow.com/questions/12720967/how-to-change-postgresql-user-password
