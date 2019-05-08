# mail function

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


