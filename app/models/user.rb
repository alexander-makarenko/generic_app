class User < ActiveRecord::Base
  attr_accessor :skip_password_validation

  before_validation :ensure_locale_is_set, on: :create
  after_validation  :remove_avatar_error_duplicates
  before_save       :downcase_email
  before_create     :generate_auth_digest,
                    :generate_email_confirmation_digest,
                    :generate_password_reset_digest

  has_secure_password

  has_attached_file :avatar, styles: { medium: '200x200#', small: '80x80#' },
    default_url: 'avatar/:style/missing.png'

  store_accessor :preferences, :locale

  validates :first_name, presence: true, length: { maximum: 30 }
  validates :last_name,  presence: true, length: { maximum: 30 }
  validates :email,      presence: true, length: { maximum: 50 },
                         uniqueness: { case_sensitive: false }
  validates :email,      format: { with: EMAIL_REGEX }, if: -> { email.present? }
  validates :password,   presence: true, unless: :skip_password_validation
  validates :password,   length: { in: 6..30 }, if: -> { password.present? }
  validates :locale,     inclusion: I18n.available_locales
  
  validates_attachment :avatar, content_type: { content_type: ['image/png',
    'image/gif', 'image/jpeg'] }, size: { less_than: 1.megabytes }

  class << self
    def digest(token)
      Digest::SHA1.hexdigest(token.to_s)
    end

    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  [:auth, :email_confirmation, :password_reset].each do |attr_name|
    define_method("#{attr_name}_token") do
      instance_variable_get("@#{attr_name}_token") || send("#{attr_name}_token=", self.class.new_token)
    end

    define_method("#{attr_name}_token=") do |token|
      instance_variable_set("@#{attr_name}_token", token)
      send("#{attr_name}_digest=", self.class.digest(token))
      save(validate: false) unless new_record?
      token
    end

    define_method("generate_#{attr_name}_digest") do
      send("#{attr_name}_digest=", self.class.digest(self.class.new_token))
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
    if options[:hashed_email]
      options[:hashed_email] == self.class.digest(email) && self
    end
  end

  def change_email_to(new_email)
    backup_email_attrs
    self.attributes = {
      email: new_email,
      email_confirmed: false,
      email_confirmed_at: nil
    }
  end

  def cancel_email_change
    restore_email_attrs
    clear_old_email_attrs
  end

  def email_change_pending?
    old_email?
  end

  def backup_email_attrs
    self.attributes = {
      old_email: email,
      old_email_confirmed: email_confirmed,
      old_email_confirmed_at: email_confirmed_at
    }
  end

  def restore_email_attrs
    self.attributes = {
      email: old_email,
      email_confirmed: old_email_confirmed,
      email_confirmed_at: old_email_confirmed_at
    }    
  end

  def clear_old_email_attrs
    self.attributes = {
      old_email: nil,
      old_email_confirmed: false,
      old_email_confirmed_at: nil
    }
  end

  def confirm_email
    self.attributes = {
      email_confirmed: true,
      email_confirmed_at: Time.zone.now,
      email_confirmation_sent_at: nil
    }
    clear_old_email_attrs if email_change_pending?
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

  def send_email(*email_types)
    email_types.each do |type|
      sent_at_attr = case type
      when :email_confirmation
        :email_confirmation_sent_at
      when :email_change_confirmation
        :email_confirmation_sent_at
      when :password_reset
        :password_reset_sent_at
      end
      update_attribute(sent_at_attr, Time.zone.now) if sent_at_attr
      UserMailer.send(type, self).deliver_now
    end
  end

  private

    def downcase_email
      email.downcase!
    end

    def ensure_locale_is_set
      self.locale ||= I18n.default_locale.to_s
    end

    def remove_avatar_error_duplicates
      errors.delete(:avatar)
    end
end