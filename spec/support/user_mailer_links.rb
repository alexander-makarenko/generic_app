def deliveries
  ActionMailer::Base.deliveries
end

def last_email
  deliveries.last
end

def link(type, options = {})
  link = extract_link(type)
  token, encoded_email = extract_token(link), extract_encoded_email(link)
  new_token, new_encoded_email = options[:token], options[:encoded_email]

  link.gsub!(token, new_token) if new_token

  case new_encoded_email
  when :missing
    link.gsub!(encoded_email, '')
  when String
    link.gsub!(encoded_email, new_encoded_email)
  end

  link
end

def extract_link(type)
  url_difference = case type
  when :activation
    'activate'
  when :password_reset
    'recover'
  end
  last_email.body.match(/href=(?:"|')(\S+#{url_difference}\S+)(?:"|')/)[1]
end

def extract_token(link)
  link.match(%r{(?://\S+/\S+/\S+/)(\S+)(?:\?)})[1]
end

def extract_encoded_email(link)
  link.match(%r{(?:\?e=)(\S+)})[1]
end