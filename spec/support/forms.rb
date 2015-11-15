include SessionsHelper

def sign_up_as(user)
  attrs = %i[ first_name last_name email password password_confirmation ]
  attrs.each { |attr| fill_in "user_#{attr}", with: user.send(attr) }
  click_button t('v.users.new.submit_button')  
end

def sign_in_as(user, **opts)
  if opts[:no_capybara] # sign in without Capybara
    sign_in(user, keep_signed_in = opts[:keep_signed_in])
  else
    fill_in 'email',    with: user.email.upcase
    fill_in 'password', with: user.password
    check t('v.sessions.new.keep_signed_in') if opts[:keep_signed_in]
    click_button t('v.sessions.new.submit_button')
  end
end

def request_password_reset(email:)
  fill_in 'password_reset_email', with: email.upcase
  click_button t('v.password_resets.new.submit_button')
end

def set_password(**args)
  args[:password_confirmation] ||= args[:password]
  args.each { |key, value| fill_in "user_#{key}", with: value }
  click_button t('v.password_resets.edit.submit_button')
end

def change_password(**args)
  args[:new_password_confirmation] ||= args[:new_password]
  args.each { |key, value| fill_in "password_change_#{key}", with: value }
  click_button t('v.password_changes.new.submit')
end

def change_name(**args)
  args.each { |key, value| fill_in "name_change_#{key}", with: value }
  click_button t('v.name_changes.new.submit')
end

def change_email(**args)
  args[:new_email_confirmation] ||= args[:new_email]
  args.each { |key, value| fill_in "email_change_#{key}", with: value }
  click_button t('v.email_changes.new.submit')
end

def attach_photo(file_name)
  # Change the file upload button's overflow property so that capybara-webkit
  # could click on it.
  if Capybara.current_driver == Capybara.javascript_driver
    execute_script("$('.btn-file').css('overflow', 'visible');")
  end

  attach_file('file-select', 'spec/support/attachments/users/avatars/' + file_name)
end