class User < ActiveRecord::Base
  attr_accessor :email_confirmation_token, :password_reset_token

  before_save   :downcase_email
  before_create :generate_auth_digest,
                :generate_email_confirmation_digest,
                :generate_password_reset_digest

  has_secure_password

  validates :first_name, presence: true, length: { maximum: 30 }
  validates :last_name,  presence: true, length: { maximum: 30 }
  validates :email,      presence: true, length: { maximum: 50 },
                         uniqueness: { case_sensitive: false }
  validates :email,      format: { with: EMAIL_REGEX }, if: -> { email.present? }
  validates :password,   presence: true
  validates :password,   length: { in: 6..30 }, if: -> { password.present? }

  def name
    "#{first_name} #{last_name}"
  end

  def authenticate_by(options={})
    if options[:digested_email]
      options[:digested_email] == self.class.digest(email) && self
    end
  end

  def confirm_email
    self.attributes = {
      email_confirmed: true,
      email_confirmed_at: Time.zone.now,
      email_confirmation_sent_at: nil
    }
  end

  def attributes_valid?(attrs)
    self.attributes = attrs
    valid?
    errors.keys.each { |key| errors.delete(key) unless attrs.include?(key) }
    errors.empty?
  end  

  def send_email(type)
    send("generate_#{type}_digest") unless send("#{type}_token")
    update_attribute("#{type}_sent_at", Time.zone.now)
    UserMailer.send(type, self).deliver_now
  end
  
  def link_expired?(link_type)
    not_valid_after = case link_type
    when :email_confirmation
      3.days.ago
    when :password_reset
      2.hours.ago
    end
    link_sent_at = send("#{link_type}_sent_at")
    link_sent_at.nil? ? true : link_sent_at < not_valid_after
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

    def generate_email_confirmation_digest
      self.email_confirmation_token = User.new_token
      self.email_confirmation_digest = User.digest(email_confirmation_token)
    end

    def generate_password_reset_digest
      self.password_reset_token = User.new_token
      self.password_reset_digest = User.digest(password_reset_token)
    end
#======================================================================
end