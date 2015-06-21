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

  describe "responds to" do
    known_methods = [
      :first_name,
      :last_name,
      :name,
      :email,
      :password_digest,
      :password,
      :password_confirmation,
      :auth_digest,
      :email_confirmation_sent_at,
      :email_confirmation_digest,
      :email_confirmed,
      :email_confirmed_at,
      :password_reset_token,
      :password_reset_digest,
      :password_reset_sent_at
    ]

    known_methods.each do |method|
      it %Q|"#{method}" method| do
        expect(subject).to respond_to method
      end
    end
  end

  it { is_expected.to be_valid }
  it { is_expected.to have_attributes(email_confirmed: false) }

  describe "with first name that" do
    context "is blank", expect_errors: 1 do
      let(:first_name) { ' ' }
    end

    context "is too long", expect_errors: 1 do
      let(:first_name) { 'a' * 31 }
    end
  end

  describe "with last name that" do
    context "is blank", expect_errors: 1 do
      let(:last_name) { ' ' }
    end

    context "is too long", expect_errors: 1 do
      let(:last_name) { 'a' * 31 }
    end
  end

  describe "with email that" do
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
      invalid_addresses = %w[ .starts-with-dot@example.com double..dot@test.org
        double.dot@test..org no_at_sign.net double@at@sign.com without@dot,com
        ends+with@dot. ]
        
      invalid_addresses.each do |address|
        describe "#{address}", expect_errors: 1 do 
          before { subject.email = address }
        end
      end
    end

    context "is of valid format" do
      valid_addresses = %w[ user@example.com first.last@somewhere.COM
        fir5t_la5t@somewhe.re FIRST+LAST@s.omwhe.re ]
      
      valid_addresses.each do |address|
        describe "#{address}" do 
          before { subject.email = address }
          it { is_expected.to be_valid }
        end
      end
    end

    context "is mixed-case" do
      let(:mixed_case_email) { 'first.LAST@example.COM' }
            
      it "is saved with email in lower case" do
        user.email = mixed_case_email.dup
        user.save
        expect(user.reload.email).to eq(mixed_case_email.downcase)
      end
    end
  end

  describe "with password that" do
    context "is blank" do
      context "on create", expect_errors: 1 do
        let(:password) { ' ' * 6 }
      end

      context "on update", expect_errors: 1 do
        subject(:persisted_user) { User.find_by(email: user.email) }
        before do
          user.save
          persisted_user.password = ' ' * 6
        end
      end
    end

    context "is too short", expect_errors: 1 do
      let(:password) { 'a' * 5 }
    end

    context "is too long", expect_errors: 1 do
      let(:password) { 'a' * 31 }      
    end

    context "does not match confirmation", expect_errors: 1 do
      before { user.password = 'mismatch' }
    end
  end

  context "when created" do
    it "is assigned auth digest" do
      user.save
      persisted_user = User.find_by(email: user.email)
      expect(persisted_user.auth_digest).to_not be_blank
    end

    it "is assigned virtual email confirmation token" do
      expect { user.save }.to change {
        user.email_confirmation_token
      }.from(nil).to(String)
    end

    it "is assigned email confirmation digest" do
      user.save
      persisted_user = User.find_by(email: user.email)
      expect(persisted_user.email_confirmation_digest).to_not be_blank
    end

    it "is assigned virtual password reset token" do
      expect { user.save }.to change {
        user.password_reset_token
      }.from(nil).to(String)
    end

    it "is assigned password reset digest" do
      user.save
      persisted_user = User.find_by(email: user.email)
      expect(persisted_user.password_reset_digest).to_not be_blank
    end
  end

  describe "#name" do
    it "returns first and last name separated by space" do
      expect(user.name).to match(
        /#{Regexp.quote(first_name)}\s{1}#{Regexp.quote(last_name)}/ )
    end
  end  

  describe "#confirm_email" do
    before { user.send_email(:email_confirmation) }

    it "sets email_confirmed attribute to true" do
      expect { user.confirm_email }.to change {
        user.email_confirmed
      }.from(false).to(true)
    end

    it "sets email_confirmed_at time" do
      expect { user.confirm_email }.to change {
        user.email_confirmed_at
      }.from(nil).to(ActiveSupport::TimeWithZone)
    end

    it "clears email_confirmation_sent_at time" do
      expect { user.confirm_email }.to change {
        user.email_confirmation_sent_at
      }.from(ActiveSupport::TimeWithZone).to(nil)
    end
  end

  describe "#assign_and_validate_attributes" do
    let(:user) { User.new }

    context "when attribute(s) is invalid" do
      let(:invalid_attrs) { Hash[email: 'not_an@email', password: ' '] }

      it "returns false" do
        expect(user.assign_and_validate_attributes(invalid_attrs)).to eq(false)
      end

      it "deletes irrelevant keys from errors hash" do
        user.assign_and_validate_attributes(invalid_attrs)
        expect(user.errors.keys).to match_array(invalid_attrs.keys)
      end
    end

    context "when attribute(s) is valid" do
      let(:valid_attrs) { Hash[email: 'valid@email.net', password: 'password'] }

      it "returns true" do
        expect(user.assign_and_validate_attributes(valid_attrs)).to eq(true)
      end

      it "leaves errors hash empty" do
        user.assign_and_validate_attributes(valid_attrs)
        expect(user.errors).to be_empty
      end
    end
  end

  describe "#send_email" do
    before { user.save }
    
    [:email_confirmation, :password_reset].each do |email_type|
      it "saves email sending time" do
        expect { user.send_email(email_type) }.to change {
          user.send("#{email_type}_sent_at")
        }.from(nil).to(ActiveSupport::TimeWithZone)
      end

      context "when #{email_type}_token is blank" do
        let(:found_user) { User.find_by(email: user.email) }
        before { user.save }

        it "generates new token" do
          expect { found_user.send_email(email_type) }.to change {
            found_user.send("#{email_type}_token")
          }.from(nil).to(String)
        end

        it "updates #{email_type}_digest" do
          expect { found_user.send_email(email_type) }.to change(
            found_user.reload, "#{email_type}_digest")
        end
      end
    end
  end

  describe "#authenticate_by" do
    before { user.save }

    describe "with :digested_email option" do
      context "when digested value corresponds to actual" do
        let(:digested_email) { described_class.digest(user.email) }
        
        it "returns self" do
          expect(user.authenticate_by(digested_email: digested_email)).to eq(user)
        end
      end

      context "when digested value does not correspond to actual" do
        let(:digested_email) { 'incorrect' }
        
        it "returns false" do
          expect(user.authenticate_by(digested_email: digested_email)).to eq(false)
        end
      end
    end
    
    [:email_confirmation, :password_reset].each do |email_type|
      it "saves email sending time" do
        expect { user.send_email(email_type) }.to change {
          user.send("#{email_type}_sent_at")
        }.from(nil).to(ActiveSupport::TimeWithZone)
      end

      context "when #{email_type}_token is blank" do
        let(:found_user) { User.find_by(email: user.email) }
        before { user.save }

        it "generates new token" do
          expect { found_user.send_email(email_type) }.to change {
            found_user.send("#{email_type}_token")
          }.from(nil).to(String)
        end

        it "updates #{email_type}_digest" do
          expect { found_user.send_email(email_type) }.to change(
            found_user.reload, "#{email_type}_digest")
        end
      end
    end
  end
end