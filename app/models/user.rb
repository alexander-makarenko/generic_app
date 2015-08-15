class User < ActiveRecord::Base 
  before_validation :ensure_locale_is_set, on: :create
  before_save       :downcase_email
  before_create     :generate_auth_digest,
                    :generate_email_confirmation_digest,
                    :generate_password_reset_digest

  has_secure_password

  store_accessor :preferences, :locale

  validates :first_name, presence: true, length: { maximum: 30 }
  validates :last_name,  presence: true, length: { maximum: 30 }
  validates :email,      presence: true, length: { maximum: 50 },
                         uniqueness: { case_sensitive: false }
  validates :email,      format: { with: EMAIL_REGEX }, if: -> { email.present? }
  validates :password,   presence: true
  validates :password,   length: { in: 6..30 }, if: -> { password.present? }
  validates :locale,     inclusion: I18n.available_locales

  class << self
    def digest(token)
      Digest::SHA1.hexdigest(token.to_s)
    end

    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  [:auth, :email_confirmation, :password_reset].each do |attr_name|
    define_method("#{attr_name}_token=") do |token|
      instance_variable_set("@#{attr_name}_token", token)
      send("#{attr_name}_digest=", User.digest(token))
      save(validate: false) unless new_record?
    end

    define_method("#{attr_name}_token") do
      send("#{attr_name}_token=", User.new_token) if instance_variable_get("@#{attr_name}_token").nil?
      instance_variable_get("@#{attr_name}_token")
    end

    define_method("generate_#{attr_name}_digest") do
      send("#{attr_name}_digest=", User.digest(User.new_token))
    end

    private "generate_#{attr_name}_digest"
  end

  def attributes_valid?(attrs)
    self.attributes = attrs
    valid?
    errors.keys.each { |key| errors.delete(key) unless attrs.include?(key) }
    errors.empty?
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

  def name
    "#{first_name} #{last_name}"
  end

  def locale
    if locale = read_attribute(:preferences).try(:[], 'locale')
      locale.to_sym
    end
  end

  def send_email(type)
    case type
    when :email_confirmation, :password_reset
      update_attribute("#{type}_sent_at", Time.zone.now)
    end
    UserMailer.send(type, self).deliver_now
  end

  private

    def downcase_email
      email.downcase!
    end

    def ensure_locale_is_set      
      self.locale ||= I18n.default_locale.to_s
    end
end