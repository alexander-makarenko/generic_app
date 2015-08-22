require 'rails_helper'

describe User do
  let(:first_name) { 'First' }
  let(:last_name)  { 'Last' }
  let(:email)      { 'first.last@example.com' }
  let(:password)   { 'qwerty123' }

  subject(:user) {
    User.new(
      first_name: first_name,
      last_name: last_name,
      email: email,
      password: password,
      password_confirmation: password
    )
  }

  it { is_expected.to be_valid }
  it { is_expected.to have_attributes(email_confirmed: false) }

  describe "with a first name that" do
    context "is blank", expect_errors: 1 do
      let(:first_name) { ' ' }
    end

    context "is too long", expect_errors: 1 do
      let(:first_name) { 'a' * 31 }
    end
  end

  describe "with a last name that" do
    context "is blank", expect_errors: 1 do
      let(:last_name) { ' ' }
    end

    context "is too long", expect_errors: 1 do
      let(:last_name) { 'a' * 31 }
    end
  end

  describe "with an email that" do
    context "is blank", expect_errors: 1 do
      let(:email) { ' ' }
    end

    context "is too long", expect_errors: 1 do
      let(:email) { ('a' * 49).insert(-10, '@').insert(-4, '.') }
    end

    context "is already taken", expect_errors: 1 do
      let(:user_with_same_email) { user.dup }
      before do
        user_with_same_email.email = user.email.swapcase
        user_with_same_email.save
      end
    end

    context "is of invalid format" do
      it "is invalid and has 1 error" do
        INVALID_EMAILS.each do |email|
          subject.email = email
          expect(subject).to have_errors(1)
        end
      end
    end

    context "is of valid format" do
      it "is valid" do
        VALID_EMAILS.each do |email|
          subject.email = email
          expect(subject).to be_valid
        end
      end
    end

    context "is mixed-case" do
      let(:mixed_case_email) { 'first.LAST@example.COM' }
            
      it "is saved with the email in lower case" do
        user.email = mixed_case_email.dup
        user.save
        expect(user.reload.email).to eq(mixed_case_email.downcase)
      end
    end
  end

  describe "with a password that" do
    context "is blank" do
      context "on create", expect_errors: 1 do
        let(:password) { ' ' * 6 }
      end

      context "on update", expect_errors: 1 do
        subject(:persisted_user) { User.find_by(email: user.email) }
        before do
          user.save
          subject.password = ' ' * 6
        end
      end
    end

    context "is too short", expect_errors: 1 do
      let(:password) { 'a' * 5 }
    end

    context "is too long", expect_errors: 1 do
      let(:password) { 'a' * 31 }
    end

    context "does not match the confirmation", expect_errors: 1 do
      before { user.password = 'mismatch' }
    end
  end

  describe "with a locale that" do
    context "is unknown" do
      context "on update", expect_errors: 1 do
        subject(:persisted_user) { User.find_by(email: user.email) }
        before do
          user.save          
          subject.attributes = { password: password, locale: 'es' }          
        end
      end
    end
  end

  context "when created" do
    subject(:persisted_user) { User.find_by(email: user.email) }
    before { user.save }

    it "is assigned a default locale" do
      expect(subject.locale).to eq I18n.default_locale
    end

    it "is assigned an auth digest" do
      expect(subject.auth_digest).to_not be_blank
    end

    it "is assigned an email confirmation digest" do
      expect(subject.email_confirmation_digest).to_not be_blank
    end
    
    it "is assigned a password reset digest" do
      expect(subject.password_reset_digest).to_not be_blank
    end
  end

  describe "#name" do
    it "returns the first and last name separated by space" do
      regex = /#{Regexp.quote(first_name)}\s{1}#{Regexp.quote(last_name)}/
      expect(user.name).to match regex
    end
  end

  describe "#locale" do
    context "when the locale attribute is not set" do
      it "returns nil" do
        expect(subject.locale).to be nil
      end
    end

    context "when the locale attribute is set" do
      it "returns its value as a symbol" do
        subject.save
        expect(subject.locale).to be_a Symbol
      end
    end
  end

  describe "#confirm_email" do
    before { user.send_email(:email_confirmation) }
    subject { user.confirm_email }

    it "sets the email_confirmed attribute to true" do
      expect { subject }.to change(user, :email_confirmed).from(false).to(true)
    end

    it "sets the email_confirmed_at time" do
      expect { subject }.to change(
        user, :email_confirmed_at
      ).from(nil).to(ActiveSupport::TimeWithZone)
    end

    it "clears the email_confirmation_sent_at time" do
      expect { subject }.to change(
        user, :email_confirmation_sent_at
      ).from(ActiveSupport::TimeWithZone).to(nil)
    end
  end

  describe "#attributes_valid?" do
    let(:user) { User.new }

    context "when an attribute(s) is invalid" do
      let(:invalid_attrs) { { email: 'not_an@email', password: ' ' } }

      it "returns false" do
        expect(user.attributes_valid?(invalid_attrs)).to eq(false)
      end

      it "deletes irrelevant keys from the errors hash" do
        user.attributes_valid?(invalid_attrs)
        expect(user.errors.keys).to match_array(invalid_attrs.keys)
      end
    end

    context "when an attribute(s) is valid" do
      let(:valid_attrs) { { email: 'valid@email.net', password: 'password' } }

      it "returns true" do
        expect(user.attributes_valid?(valid_attrs)).to eq(true)
      end

      it "leaves the errors hash empty" do
        user.attributes_valid?(valid_attrs)
        expect(user.errors).to be_empty
      end
    end
  end

  describe "#send_email" do
    before { user.save }

    shared_examples "shared" do
      subject(:send_email) { user.send_email(email_type) }

      it "saves the email sending time" do
        expect { send_email }.to change(
          user, "#{email_type}_sent_at"
        ).from(nil).to(ActiveSupport::TimeWithZone)
      end
    end

    it "sends an email of specified type" do
      [:welcome, :email_confirmation, :password_reset].each do |email_type|
        expect { user.send_email(email_type) }.to change(deliveries, :count).by(1)
      end
    end

    context "with a :password_reset option" do
      let(:email_type) { :password_reset }
      include_examples "shared"
    end

    context "with an :email_confirmation option" do
      let(:email_type) { :email_confirmation }
      include_examples "shared"
    end
  end

  describe "#authenticate_by" do
    before { user.save }

    describe "with a :digested_email option" do
      subject(:return_value) { user.authenticate_by(digested_email: digested_email) }

      context "when a digested value corresponds to the actual" do
        let(:digested_email) { described_class.digest(user.email) }

        it "returns self" do
          expect(return_value).to eq(user)
        end
      end

      context "when a digested value does not correspond to the actual" do
        let(:digested_email) { 'incorrect' }

        it "returns false" do
          expect(return_value).to eq(false)
        end
      end
    end
  end

  shared_examples attribute_setter: true do
    attr_name = metadata[:description].match(/#(.*)_.*/)[1]
    subject { user.send("#{attr_name}_token=", 'foo') }

    it "assigns a value to the #{attr_name}_token attribute" do
      expect { subject }.to change {
        user.instance_variable_get("@#{attr_name}_token")
      }.to('foo')
    end

    it "returns the assigned value" do
      expect(subject).to eq 'foo'
    end

    it "updates the #{attr_name}_digest attribute" do
      expect { subject }.to change(user, "#{attr_name}_digest")
    end

    context "when the record is persisted" do
      before { user.save }

      it "updates the #{attr_name}_digest column in the database" do
        expect { subject }.to change(user.reload, "#{attr_name}_digest")
      end
    end
  end

  shared_examples attribute_getter: true do
    attr_name = metadata[:description].match(/#(.*)_.*/)[1]
    subject { user.send("#{attr_name}_token") }

    context "when the #{attr_name}_token attribute is nil" do
      it "assigns it a new token through the #{attr_name}_token= setter" do
        expect(user.instance_variable_get("@#{attr_name}_token")).to be_nil
        expect(user).to receive("#{attr_name}_token=").with(String)
        subject
      end

      it "returns the new token" do
        expect(subject).to be_a(String)
      end
    end

    context "when the #{attr_name}_token attribute is not nil" do
      before { user.send("#{attr_name}_token=", 'foo') }

      it "return its value" do
        expect(subject).to eq('foo')
      end
    end
  end

  describe "#auth_token", :attribute_getter do end
  describe "#email_confirmation_token", :attribute_getter do end
  describe "#password_reset_token", :attribute_getter do end

  describe "#auth_token=", :attribute_setter do end
  describe "#email_confirmation_token=", :attribute_setter do end
  describe "#password_reset_token=", :attribute_setter do end
end