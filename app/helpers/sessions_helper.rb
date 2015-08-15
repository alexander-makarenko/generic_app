module SessionsHelper

  def sign_in(user, keep_signed_in = nil)    
    auth_token = user.auth_token
    if keep_signed_in == '1'
      cookies.permanent[:auth_token] = auth_token
    else
      cookies[:auth_token] = auth_token
    end
    cookies[:locale] = user.locale
    self.current_user = user
  end

  def sign_out
    if current_user
      current_user.update_attribute(:auth_digest, User.digest(User.new_token))
      cookies.delete(:auth_token)
      self.current_user = nil
    end
  end

  def current_user
    @current_user ||= User.find_by(auth_digest: User.digest(cookies[:auth_token]))
  end

  def current_user=(user)
    @current_user = user
  end

  def signed_in?
    !current_user.nil?
  end
end