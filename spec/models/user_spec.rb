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

  it "has an avatar attachment" do
    expect(subject).to have_attached_file(:avatar)
  end

  describe "with an avatar attachment that" do
    let(:errors_hash) { subject.errors.messages }

    context "is too large" do
      before { subject.avatar_file_size = 2.megabytes }
      
      it { is_expected.to have_errors(1) }

      it "does not has an :avatar key in the errors hash" do
        subject.valid?
        expect(errors_hash).to_not include :avatar
      end

      it "has an :avatar_file_size key in the errors hash" do
        subject.valid?
        expect(errors_hash).to include :avatar_file_size
      end
    end

    context "has invalid content type" do
      let(:invalid_content_types) { %w[ text/plain text/xml text/html ] }
      
      it "is invalid and has 1 error" do
        invalid_content_types.each do |type|
          subject.avatar_content_type = type
          expect(subject).to have_errors(1)
        end
      end

      it "does not have an :avatar key in the errors hash" do
        subject.avatar_content_type = invalid_content_types.first
        subject.valid?
        expect(errors_hash).to_not include :avatar
      end

      it "has an :avatar_content_type key in the errors hash" do
        subject.avatar_content_type = invalid_content_types.first
        subject.valid?
        expect(errors_hash).to include :avatar_content_type
      end
    end

    context "has valid content type" do
      let(:valid_content_types) { %w[ image/png image/gif image/jpeg ] }

      it "is valid" do
        valid_content_types.each do |type|
          subject.avatar_content_type = type
          expect(subject).to be_valid
        end
      end
    end
  end
  
  describe "with a first name that" do
    context "is blank" do
      let(:first_name) { ' ' }
      it { is_expected.to have_errors(1) }
    end

    context "is too long"do
      let(:first_name) { 'a' * 31 }
      it { is_expected.to have_errors(1) }
    end
  end

  describe "with a last name that" do
    context "is blank" do
      let(:last_name) { ' ' }
      it { is_expected.to have_errors(1) }
    end

    context "is too long" do
      let(:last_name) { 'a' * 31 }
      it { is_expected.to have_errors(1) }
    end
  end

  describe "with an email that" do
    context "is blank" do
      let(:email) { ' ' }
      it { is_expected.to have_errors(1) }
    end

    context "is too long" do
      let(:email) { ('a' * 49).insert(-10, '@').insert(-4, '.') }
      it { is_expected.to have_errors(1) }
    end

    context "is already taken" do
      let(:user_with_same_email) { user.dup }
      before do
        user_with_same_email.email = user.email.swapcase
        user_with_same_email.save
      end

      it { is_expected.to have_errors(1) }
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
      let(:blank_password) { ' ' * 6 }

      context "on create" do
        let(:password) { blank_password }
        it { is_expected.to have_errors(1) }
      end

      context "on update"do
        subject(:persisted_user) { User.find_by(email: user.email) }
        before do
          user.save
          subject.password = blank_password
        end

        it { is_expected.to have_errors(1) }
      end

      context "and the skip_password_validation attribute set to true" do
        let(:password) { blank_password }
        before { subject.skip_password_validation = true }

        it { is_expected.to be_valid }
      end
    end

    context "is too short" do
      let(:password) { 'a' * 5 }
      it { is_expected.to have_errors(1) }
    end

    context "is too long" do
      let(:password) { 'a' * 31 }
      it { is_expected.to have_errors(1) }
    end

    context "does not match the confirmation" do
      before { subject.password = 'mismatch' }
      it { is_expected.to have_errors(1) }
    end
  end

  describe "with a locale that" do
    context "is unknown" do
      context "on update" do
        subject(:persisted_user) { User.find_by(email: user.email) }
        before do
          user.save          
          subject.attributes = { password: password, locale: 'es' }          
        end

        it { is_expected.to have_errors(1) }
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
    let(:user) { FactoryGirl.create(:user, :email_confirmation_sent) }
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

    context "when an email change is pending" do
      let(:user) { FactoryGirl.create(:user, :email_change_pending) }

      it "calls #clear_old_email_attrs" do
        expect(user).to receive(:clear_old_email_attrs)
        subject
      end
    end
  end

  describe "#change_email_to" do
    let(:user) { FactoryGirl.create(:user, :email_confirmed) }
    let(:new_email) { 'new.email@example.com' }
    subject { user.change_email_to(new_email) }

    it "calls #backup_email_attrs" do
      expect(user).to receive(:backup_email_attrs)
      subject
    end

    it "sets the email_confirmed attribute to false" do
      expect { subject }.to change(user, :email_confirmed).from(true).to(false)
    end

    it "clears the email_confirmed_at time" do
      expect { subject }.to change(user, :email_confirmed_at).to(nil)
    end

    it "updates the email attribute" do
      expect { subject }.to change(user, :email).to(new_email)
    end    
  end

  describe "#cancel_email_change" do
    let(:user) { FactoryGirl.create(:user, :email_change_pending) }
    subject { user.cancel_email_change }

    it "calls #restore_email_attrs" do
      expect(user).to receive(:restore_email_attrs)
      subject
    end

    it "calls #clear_old_email_attrs" do
      expect(user).to receive(:clear_old_email_attrs)
      subject
    end
  end

  describe "#email_change_pending" do
    subject { user.email_change_pending? }

    context "when old_email is not nil" do
      before { user.old_email = 'old' + user.email }

      it "returns true" do
        expect(subject).to eq(true)
      end
    end

    context "when old_email is nil" do
      it "returns false" do
        expect(subject).to eq(false)
      end
    end
  end

  describe "#backup_email_attrs" do
    let(:user) { FactoryGirl.create(:user, :email_confirmed) }
    let!(:original_email) { user.email }
    let!(:original_email_confirmed) { user.email_confirmed }
    let!(:original_email_confirmed_at) { user.email_confirmed_at }
    subject { user.backup_email_attrs }

    it "stores the original email in the old_email attribute" do
      expect { subject }.to change(user, :old_email).from(nil).to(original_email)
    end

    it "stores the original email's confirmation status in the old_email_confirmed attribute" do
      expect { subject }.to change(
        user, :old_email_confirmed
      ).from(false).to(original_email_confirmed)
    end

    it "stores the original email's confirmation time in the old_email_confirmed_at attribute" do
      expect { subject }.to change(
        user, :old_email_confirmed_at
      ).from(nil).to(original_email_confirmed_at)
    end
  end

  describe "#restore_email_attrs" do
    let(:user) { FactoryGirl.create(:user, :email_change_pending) }
    let!(:original_email) { user.old_email }
    let!(:original_email_confirmed) { user.old_email_confirmed }
    let!(:original_email_confirmed_at) { user.old_email_confirmed_at }
    subject { user.restore_email_attrs }

    it "restores the original email from the old_email attribute" do
      expect { subject }.to change(user, :email).to(original_email)
    end

    it "restores the original email's confirmation status from the old_email_confirmed attribute" do
      expect { subject }.to change(user, :email_confirmed).to(original_email_confirmed)
    end

    it "restores the original email's confirmation time from the old_email_confirmed_at attribute" do
      expect { subject }.to change(user, :email_confirmed_at).to(original_email_confirmed_at)
    end    
  end

  describe "#clear_old_email_attrs" do
    let(:user) { FactoryGirl.create(:user, :email_change_pending) }
    subject { user.clear_old_email_attrs }

    it "clears the old_email attribute" do      
      expect { subject }.to change(user, :old_email).from(String).to(nil)
    end

    it "sets the old_email_confirmed attribute to false" do
      expect { subject }.to change(
        user, :old_email_confirmed
      ).from(true).to(false)
    end

    it "clears the old_email_confirmed_at time" do      
      expect { subject }.to change(
        user, :old_email_confirmed_at
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
    before do
      subject.old_email = 'old@example.com'
      subject.save
    end

    shared_examples "shared" do
      it "saves the email sending time" do
        expect { subject.send_email(email_type) }.to change(
          subject, sent_at_attr
        ).from(nil).to(ActiveSupport::TimeWithZone)
      end
    end
    
    it "sends an email(s) of the specified type(s)" do
      email_types = [:welcome, :email_change_confirmation, :email_changed_notice,
        :email_confirmation, :password_reset]

      expect { subject.send_email(*email_types) }.to change(deliveries, :count).by(email_types.count)
    end

    context "with a :password_reset option" do
      let(:email_type) { :password_reset }
      let(:sent_at_attr) { :password_reset_sent_at }
      include_examples "shared"
    end

    context "with an :email_confirmation option" do
      let(:email_type) { :email_confirmation }
      let(:sent_at_attr) { :email_confirmation_sent_at }
      include_examples "shared"
    end

    context "with an :email_change_confirmation option" do
      let(:email_type) { :email_change_confirmation }
      let(:sent_at_attr) { :email_confirmation_sent_at }
      include_examples "shared"
    end
  end

  describe "#authenticate_by" do
    before { user.save }

    describe "with a :hashed_email option" do
      subject(:return_value) { user.authenticate_by(hashed_email: hashed_email) }

      context "when a digested value corresponds to the actual" do
        let(:hashed_email) { described_class.digest(user.email) }

        it "returns self" do
          expect(return_value).to eq(user)
        end
      end

      context "when a digested value does not correspond to the actual" do
        let(:hashed_email) { 'incorrect' }

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