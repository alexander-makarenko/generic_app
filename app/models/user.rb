class User < ActiveRecord::Base

  before_save { email.downcase! }
  before_create { generate_auth_digest }

  EMAIL_REGEX = /\A[\w+-]+(\.[\w-]+)*@[a-z\d]+(\.[a-z\d-]+)*(\.[a-z]{2,4})\z/i

  has_secure_password 

  validates :name,     presence: true,
                       length: { maximum: 50 }
  validates :email,    presence: true,
                       length: { maximum: 50 },
                       uniqueness: { case_sensitive: false },
                       format: { with: EMAIL_REGEX }
  validates :password, length: { in: 6..30 }

  class << self
    def new_random_token
      SecureRandom.urlsafe_base64
    end

    def encrypt(token)
      Digest::SHA1.hexdigest(token.to_s)
    end
  end

  private

    def generate_auth_digest
      self.auth_digest = User.encrypt(User.new_random_token)
    end
end