def deliveries
  ActionMailer::Base.deliveries
end

def last_email
  deliveries.last
end

def link(type, options = {})
  link = extract_link(type)
  hashed_email, token = extract_hashed_email(link), extract_token(link)
  new_hashed_email, new_token = options[:hashed_email], options[:token]

  link.gsub!(token, new_token) if new_token
  link.gsub!(hashed_email, new_hashed_email) if new_hashed_email
  link
end

def extract_link(type)
  url_difference = case type
  when :email_confirmation
    'confirm'
  when :password_reset
    'recover'
  end  
  last_email.body.match(%r[(?:href=(?:"|')\S+://[^/]+)(\S+#{url_difference}\S+)(?:"|')])[1]
end

def extract_token(link)
  link.match(%r[(?:/\S+/\S+/)(\S+)])[1]
end

def extract_hashed_email(link)
  link.match(%r[(?:/\S+/)(\S+)(?:/)])[1]
end