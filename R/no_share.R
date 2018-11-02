# this is a script to share files with the norman owncloud

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# copy --------------------------------------------------------------------
todo_no = list.files(share)
for (i in seq_along(todo_no)) {
  file = todo_no[i]
  file.copy(file.path(share, file),
            file.path('/home/andreas/Documents/ownCloud/norman', file),
            overwrite = TRUE)
}

# cleaning ----------------------------------------------------------------
rm(todo_no, file)

