class User < ActiveRecord::Base
  class AlreadyActivated < StandardError; end
  
  EMAIL_REGEX = /\A[\w+-]+(\.[\w-]+)*@[a-z\d]+(\.[a-z\d-]+)*(\.[a-z]{2,4})\z/i

  attr_accessor :activation_token, :password_reset_token

  before_save   :downcase_email
  before_create :generate_auth_digest,
                :generate_activation_digest,
                :generate_password_reset_digest

  has_secure_password

  validates :first_name, presence: true, length: { maximum: 30 }
  validates :last_name,  presence: true, length: { maximum: 30 }
  validates :email,      presence: true, length: { maximum: 50 },
                         uniqueness: { case_sensitive: false }
  validates :email,      format: { with: EMAIL_REGEX }, unless: -> { email.blank? }
  validates :password,   presence: true
  validates :password,   length: { in: 6..30 }, unless: -> { password.blank? }

  def name
    "#{first_name} #{last_name}"
  end

  def authenticated(attribute, value)
    case attribute
    when :password
      authenticate(value)
    when :activation_token
      activation_digest == User.digest(value) && self
    when :password_reset_token
      password_reset_digest == User.digest(value) && self
    end
  end

  def send_email(type)
    send("generate_#{type}_digest") unless send("#{type}_token")
    update_attribute("#{type}_sent_at", Time.zone.now)
    UserMailer.send(type, self).deliver_now
  end
  
  def link_expired?(link_type)
    not_valid_after = case link_type
    when :activation
      3.days.ago
    when :password_reset
      2.hours.ago
    end
    link_sent_at = send("#{link_type}_sent_at")
    link_sent_at.nil? ? true : link_sent_at < not_valid_after
  end

  def assign_and_validate_attributes(attrs)
    self.attributes = attrs
    valid?
    errors.keys.each { |key| errors.delete(key) unless attrs.include?(key) }
    errors.empty?
  end

  class << self
    def new_token
      SecureRandom.urlsafe_base64
    end

    def digest(token)
      Digest::SHA1.hexdigest(token.to_s)
    end
  end

  private
    def downcase_email
      email.downcase!
    end

#============================ REFACTOR ================================
# perhaps add a method generate_token_and_digest(:type)
    def generate_auth_digest
      self.auth_digest = User.digest(User.new_token)
    end

    def generate_activation_digest
      self.activation_token = User.new_token
      self.activation_digest = User.digest(activation_token)
    end

    def generate_password_reset_digest
      self.password_reset_token = User.new_token
      self.password_reset_digest = User.digest(password_reset_token)
    end
#======================================================================
end