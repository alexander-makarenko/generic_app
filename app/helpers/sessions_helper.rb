module SessionsHelper

  def sign_in(user, keep_signed_in = nil)
    auth_token = User.new_token
    user.update_attribute(:auth_digest, User.digest(auth_token))
    if keep_signed_in
      cookies.permanent[:auth_token] = auth_token
    else
      cookies[:auth_token] = auth_token
    end
    self.current_user = user
  end

  def signed_in?
    !current_user.nil?
  end

  def sign_out
    current_user.update_attribute(:auth_digest, User.digest(User.new_token))
    cookies.delete(:auth_token)
    self.current_user = nil
  end

  def current_user
    @current_user ||= User.find_by(auth_digest: User.digest(cookies[:auth_token]))
  end

  def current_user=(user)
    @current_user = user
  end

  def current_user?(user)
    user == current_user
  end
end