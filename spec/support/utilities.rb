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

def sign_in_as(user, opts={})
  fill_in 'Email',    with: user.email.upcase
  fill_in 'Password', with: user.password
  check('Keep me signed in') if opts[:keep_signed_in]
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