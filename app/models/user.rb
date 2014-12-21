class User < ActiveRecord::Base
  EMAIL_REGEX = /\A[\w+-]+(\.[\w-]+)*@[a-z\d]+(\.[a-z\d-]+)*(\.[a-z]{2,4})\z/i

  attr_accessor :activation_token, :password_reset_token

  before_save   :downcase_email
  before_create :generate_auth_digest,
                :generate_activation_digest,
                :generate_password_reset_digest

  has_secure_password

  validates :name,     presence: true,
                       length: { maximum: 50 }
  validates :email,    presence: true,
                       length: { maximum: 50 },
                       uniqueness: { case_sensitive: false }
  validates :email,    format: { with: EMAIL_REGEX }, unless: -> { email.blank? }
  validates :password, presence: true, allow_blank: false
  validates :password, length: { in: 6..30 }, unless: -> { password.blank? }

  def authenticated(attribute, value)
    case attribute
    when :password
      self.authenticate(value)
    when :activation_token
      self.activation_digest == User.digest(value) && self
    when :password_reset_token
      self.password_reset_digest == User.digest(value) && self
    end
  end

  def send_link(link_type)
    unless self.send("#{link_type.to_s}_token")
      self.send("generate_#{link_type.to_s}_digest")
      save(validate: false)
    end
    UserMailer.send(link_type, self).deliver_now
    self.update_attribute("#{link_type}_email_sent_at", Time.zone.now)
  end
  
  def link_expired?(link_type)
    time_to_expire = case link_type
    when :activation
      2.days.ago
    when :password_reset
      2.hours.ago    
    end
    self.send("#{link_type}_email_sent_at") < time_to_expire
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
      self.email.downcase!
    end

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
end