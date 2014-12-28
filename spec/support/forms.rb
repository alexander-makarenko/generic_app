include SessionsHelper

def sign_up_as(user)
  fill_in 'user[name]',                  with: user.name
  fill_in 'user[email]',                 with: user.email.upcase
  fill_in 'user[password]',              with: user.password
  fill_in 'user[password_confirmation]', with: user.password_confirmation
  click_button I18n.t('v.users.new.submit_button')
end

def sign_in_as(user, options={})
  if options[:no_capybara] # sign in without Capybara
    sign_in(user, keep_signed_in = options[:keep_signed_in])
  else
    fill_in 'email',    with: user.email.upcase
    fill_in 'password', with: user.password
    check I18n.t('v.sessions.new.keep_signed_in') if options[:keep_signed_in]
    click_button I18n.t('v.sessions.new.submit_button')
  end
end

def update_profile_of(user, options={})
  original_values = Hash[
    name: user.name,
    email: user.email.upcase,
    password: user.password ]
  
  new_values = original_values.merge(options)

  fill_in 'user[name]',     with: new_values[:name]
  fill_in 'user[email]',    with: new_values[:email]
  fill_in 'user[password]', with: new_values[:password]
  click_button I18n.t('v.users.edit.submit_button')
end

def update_password_with(options={})  
  fill_in 'password_reset[password]',              with: options[:password]
  fill_in 'password_reset[password_confirmation]', with: options[:confirmation]
  click_button I18n.t('v.password_resets.edit.submit_button')
end

def rerequest_activation_email_as(user)
  fill_in 'email',    with: user.email.upcase
  fill_in 'password', with: user.password
  click_button I18n.t('v.account_activations.new.submit_button')
end

def request_password_reset(email)
  fill_in 'password_reset[email]', with: email.upcase
  click_button I18n.t('v.password_resets.new.submit_button')
end