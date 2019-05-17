# mail function

# mailR -------------------------------------------------------------------
#! depends on rJava::
mail = function(sender, recipients, pw, subj, body) {
  # debuging: https://github.com/rpremraj/mailR/issues/77
  mailR::send.mail(from = sender,
                   to = recipients,
                   subject = subj,
                   body = body,
                   smtp = list(host.name = "smtp.gmail.com", port = 465, 
                               user.name = sender,            
                               passwd = pw, ssl = TRUE),
                   authenticate = TRUE,
                   send = TRUE)  
}

# swaks -------------------------------------------------------------------
# needs swaks installed
swaks_mail = function(recip, subj, msg, user, pw, attach) {
  to = paste0('--to ', recip, collapse = ' ')
  header = paste0('--header "Subject:', subj, '"')
  body = paste0('--body "', msg, '"')
  au = paste0('-au ', user)
  ap = paste0('-ap ', pw)
  att = paste('--attach', attach)
  
  cmd = paste('swaks',
              paste0(to, collapse = ' '), '-s smtp.gmail.com:587 -tls',
              header, body,
              au, ap,
              paste0(att, collapse = ' '),
              sep = ' ')
  
  system(cmd)
  message(cmd)
}

# linux: mailx ------------------------------------------------------------
mailx = function(recip = NULL, sub = NULL, body = NULL, attachment = NULL) {
  if (is.null(recip)) {
    stop('Provide recipient.')
  }
  if (is.null(sub)) {
    sub = ''
  }
  if (is.null(body)) {
    body = ''
  }
  if (is.null(attachment)) {
    attachment = ''
  } else {
    attachment = paste0('-A ', attachment, collapse = ' ')
  }

  cmd = sprintf('echo "%s" | mail -s "%s" %s %s',
                body, sub, attachment, recipient)
  
  system(cmd)
  print(cmd)
  message('Sent mail to: ', recip)
}





