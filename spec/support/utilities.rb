RSpec.configure do |config|
  config.include ShowMeTheCookies, :type => :feature
end

# emulate reopening of the browser by deleting session cookies
def expire_session_cookies
  get_me_the_cookies.each do |cookie|
    delete_cookie(cookie[:name]) if cookie[:expires].nil?
  end
end

def fail_to_sign_up
  click_button 'Create my account'
end

def sign_up_as(user)
  fill_in 'Name',             with: user.name
  fill_in 'Email',            with: user.email
  fill_in 'Password',         with: user.password
  fill_in 'Confirm password', with: user.password_confirmation
  click_button 'Create my account'
end

def fail_to_sign_in
  click_button 'Sign in'
end

def sign_in_as(user, options={})
  fill_in 'Email',    with: user.email.upcase
  fill_in 'Password', with: user.password
  
  # 'Keep me signed in' is not checked by default
  if options.fetch(:keep_signed_in, false)
    check('Keep me signed in')
  end

  # user is activated by default
  if options.fetch(:activated, true)
    user.attributes = { activated: true, activated_at: Time.zone.now }
    user.save(validate: false)
  end

  click_button 'Sign in'
end

def fail_to_update_profile
  click_button 'Save changes'
end

def update_profile_of(user, opts={})
  original_attrs = { name: user.name, email: user.email, password: user.password }
  new_attrs = original_attrs.merge(opts[:with])

  fill_in 'Name',     with: new_attrs[:name]
  fill_in 'Email',    with: new_attrs[:email]
  fill_in 'Password', with: new_attrs[:password]
  click_button 'Save changes'
end

def deliveries
  ActionMailer::Base.deliveries
end

def clear_deliveries
  deliveries.clear
end

def last_email
  deliveries.last
end

def activation_link
  last_email.body.match(/href=(?:"|')(\S+activate\S+)(?:"|')/i)[1]
end

def activation_link_with_incorrect_token
  activation_link.gsub(/(token=)(.+)/, '\\1incorrect')
end