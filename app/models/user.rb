class User < ActiveRecord::Base

  before_save { email.downcase! }

  EMAIL_REGEX = /\A[\w+-]+(\.[\w-]+)*@[a-z\d]+(\.[a-z\d-]+)*(\.[a-z]{2,4})\z/i

  has_secure_password 

  validates :name,     presence: true,
                       length: { maximum: 50 }
  validates :email,    presence: true,
                       length: { maximum: 50 },
                       uniqueness: { case_sensitive: false },
                       format: { with: EMAIL_REGEX }
  validates :password, length: { in: 6..30 }
end