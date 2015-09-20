def deliveries
  ActionMailer::Base.deliveries
end

def last_email
  deliveries.last
end

def get_urls_from(html_string)
  URI.extract(html_string, 'http').uniq.map { |uri_string| URI.parse(uri_string) }
end

def get_hashed_email_from(path)
  path.split('/')[3]
end

def get_token_from(path)
  path.split('/')[4]
end

[:hashed_email, :token].each do |segment|
  define_method("replace_#{segment}!") do |path, new_value|
    path.sub!(send("get_#{segment}_from", path), new_value)
  end
end

[:password_reset, :email_confirmation].each do |type_of|
  define_method("#{type_of}_link") do |**opts|
    path = get_urls_from(last_email.body.to_s).first.path
    opts.each { |segment, new_value| send("replace_#{segment}!", path, new_value) }
    path
  end
end