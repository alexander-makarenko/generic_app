class User < ActiveRecord::Base
  attr_accessor :activation_token

  before_save   :downcase_email
  before_create :generate_auth_digest
  before_create :generate_activation_digest

  EMAIL_REGEX = /\A[\w+-]+(\.[\w-]+)*@[a-z\d]+(\.[a-z\d-]+)*(\.[a-z]{2,4})\z/i

  has_secure_password

  validates :name,     presence: true,
                       length: { maximum: 50 }
  validates :email,    presence: true,
                       length: { maximum: 50 },
                       uniqueness: { case_sensitive: false }
  validates :email,    format: { with: EMAIL_REGEX }, unless: -> { email.blank? }
  validates :password, presence: true, on: :update
  validates :password, length: { in: 6..30 }, unless: -> { password.blank? }

  def send_activation_link
    unless activation_token
      generate_activation_digest
      save(validate: false)
    end
    UserMailer.account_activation(self).deliver
    self.update_attribute(:activation_email_sent_at, Time.zone.now)
  end

  def activated_in_time?
    self.activation_email_sent_at > 2.days.ago
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
end