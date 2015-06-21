include SessionsHelper

def sign_up_as(user)
  fill_in 'user_first_name',            with: user.first_name
  fill_in 'user_last_name',             with: user.last_name
  fill_in 'user_email',                 with: user.email.upcase
  fill_in 'user_password',              with: user.password
  fill_in 'user_password_confirmation', with: user.password_confirmation
  click_button t('v.users.new.submit_button')  
end

def sign_in_as(user, options={})
  if options[:no_capybara] # sign in without Capybara
    sign_in(user, keep_signed_in = options[:keep_signed_in])
  else
    fill_in 'email',    with: user.email.upcase
    fill_in 'password', with: user.password
    check t('v.sessions.new.keep_signed_in') if options[:keep_signed_in]
    click_button t('v.sessions.new.submit_button')
  end
end

def change_password_of(user, custom_values={})
  values = {
    current_password: user.password,
    new_password:     user.password,
    confirmation:     user.password
  }
  values.merge!(custom_values) if custom_values

  fill_in 'password_change_current_password',          with: values[:current_password]
  fill_in 'password_change_new_password',              with: values[:new_password]
  fill_in 'password_change_new_password_confirmation', with: values[:confirmation]
  click_button t('v.password_changes.new.submit')
end

def change_name_of(user, opts={})  
  fill_in 'name_change_new_first_name', with: opts[:to][0]
  fill_in 'name_change_new_last_name',  with: opts[:to][1]
  click_button t('v.name_changes.new.submit')
end

# def change_email_of(user, opts={})
#   fill_in 'email', with: opts[:to]
#   click_button t('v.email_changes.new.submit')
# end

def update_password_with(values={})  
  fill_in 'user_password',              with: values[:password]
  fill_in 'user_password_confirmation', with: values[:confirmation]
  click_button t('v.password_resets.edit.submit_button')
end

def request_password_reset(email)
  fill_in 'password_reset_email', with: email.upcase
  click_button t('v.password_resets.new.submit_button')
end