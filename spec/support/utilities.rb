RSpec.configure do |config|
  config.include ShowMeTheCookies, :type => :feature
end

# emulate reopening of the browser by deleting session cookies
def expire_session_cookies
  get_me_the_cookies.each do |cookie|
    delete_cookie(cookie[:name]) if cookie[:expires].nil?
  end
end

def sign_up_as(user)
  fill_in 'Name',             with: user.name
  fill_in 'Email',            with: user.email.upcase
  fill_in 'Password',         with: user.password
  fill_in 'Confirm password', with: user.password_confirmation
  click_button 'Create my account'
end

def sign_in_as(user, options={})
  fill_in 'Email',    with: user.email.upcase
  fill_in 'Password', with: user.password
  check('Keep me signed in') if options[:keep_signed_in]
  click_button 'Sign in'
end

def update_profile_of(user, options={})
  original_values = Hash[
    name: user.name,
    email: user.email.upcase,
    password: user.password ]
  
  new_values = original_values.merge(options[:with])

  fill_in 'Name',     with: new_values[:name]
  fill_in 'Email',    with: new_values[:email]
  fill_in 'Password', with: new_values[:password]
  click_button 'Save changes'
end

def rerequest_activation_email_as(user)
  fill_in 'Email',    with: user.email.upcase
  fill_in 'Password', with: user.password
  click_button 'Submit'
end

def deliveries
  ActionMailer::Base.deliveries
end

def last_email
  deliveries.last
end

def activation_link(options = {})
  link_regex = /href=(?:"|')(\S+activate\S+)(?:"|')/i

  link = last_email.body.match(link_regex)[1]

  case options[:with]
  when :invalid_token
    link.gsub!(/(activate\/)(.+)(\?)/, '\\1incorrect\\3')
  when :invalid_encoded_email
    link.gsub!(/(\?e=)(.+)/, '\\1incorrect')
  when :no_encoded_email
    link.gsub!(/\?e=.+/, '')
  end

  link
end