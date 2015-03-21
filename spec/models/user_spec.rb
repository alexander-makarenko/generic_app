require 'rails_helper'

describe User do
  let(:first_name) { 'First' }
  let(:last_name)  { 'Last' }
  let(:email)      { 'first.last@example.com' }
  let(:password)   { 'qwerty123' }

  subject(:user) { User.new(
    first_name: first_name,
    last_name: last_name,
    email: email,
    password: password,
    password_confirmation: password) }

  [ :first_name,
    :last_name,
    :name,
    :email,
    :password_digest,
    :password,
    :password_confirmation,
    :authenticated,
    :auth_digest,    
    :activation_sent_at,
    :activation_digest,
    :activated,
    :activated_at,
    :password_reset_token,
    :password_reset_digest,
    :password_reset_sent_at    
  ].each do |method|
    it %Q|responds to "#{method}" method| do
      expect(user).to respond_to method
    end
  end

  it { is_expected.to be_valid }
  it { is_expected.to_not be_activated }

  describe "with first name that" do
    context "is blank" do
      let(:first_name) { ' ' }
      include_examples "is invalid and has errors", 1
    end

    context "is too long" do
      let(:first_name) { 'a' * 31 }

      include_examples "is invalid and has errors", 1
    end
  end

  describe "with last name that" do
    context "is blank" do
      let(:last_name) { ' ' }
      include_examples "is invalid and has errors", 1
    end

    context "is too long" do
      let(:last_name) { 'a' * 31 }

      include_examples "is invalid and has errors", 1
    end
  end

  describe "with email that" do
    context "is blank" do
      let(:email) { ' ' }

      include_examples "is invalid and has errors", 1
    end

    context "is too long" do
      let(:email) { "#{'a' * 39}@example.com" }

      include_examples "is invalid and has errors", 1
    end

    context "is already taken" do
      let(:user_with_same_email) { user.dup }
      before do
        user_with_same_email.email = user.email.swapcase
        user_with_same_email.save
      end

      include_examples "is invalid and has errors", 1
    end

    context "is of invalid format" do
      let(:addresses) { %w[ .starts-with-dot@example.com double..dot@test.org
        double.dot@test..org no_at_sign.net double@at@sign.com without@dot,com
        ends+with@dot. ] }
      
      specify "is invalid and has an error" do
        addresses.each do |invalid_address|
          user.email = invalid_address
          expect(user).to be_invalid
          expect(user.errors.count).to eq(1)
        end
      end
    end

    context "is of valid format" do
      let(:addresses) { %w[ user@example.com first.last@somewhere.COM
        fir5t_la5t@somewhe.re FIRST+LAST@s.omwhe.re ] }
      
      specify "is valid" do
        addresses.each do |valid_address|
          user.email = valid_address
          expect(user).to be_valid
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
      context "on create" do
        let(:password) { ' ' * 6 }
        
        include_examples "is invalid and has errors", 1
      end

      context "on update" do
        subject(:persisted_user) { User.find_by(email: user.email) }
        before do
          user.save
          persisted_user.password = ' ' * 6
        end        

        include_examples "is invalid and has errors", 1
      end
    end

    context "is too short" do
      let(:password) { 'a' * 5 }

      include_examples "is invalid and has errors", 1
    end

    context "is too long" do
      let(:password) { 'a' * 73 }

      include_examples "is invalid and has errors", 1
    end

    context "does not match confirmation" do
      before { user.password = 'mismatch' }

      include_examples "is invalid and has errors", 1
    end
  end

  context "when created" do
    it "is assigned auth digest" do
      user.save
      persisted_user = User.find_by(email: user.email)
      expect(persisted_user.auth_digest).to_not be_blank
    end

    it "is assigned virtual activation token" do
      expect { user.save }.to change {
        user.activation_token
      }.from(nil).to(String)
    end

    it "is assigned activation digest" do
      user.save
      persisted_user = User.find_by(email: user.email)
      expect(persisted_user.activation_digest).to_not be_blank
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

  describe "#authenticated" do
    let(:found_user) { User.find_by(email: user.email) }
    before { user.save }

    accepted_attributes = [:password, :activation_token,
      :password_reset_token]
    accepted_attributes.each do |attribute|
      context "with correct #{attribute}" do        
        it "returns false" do
          expect(found_user.authenticated(attribute, 'incorrect')).to eq(false)
        end
      end        

      context "with incorrect #{attribute}" do
        it "returns user" do
          expect(found_user.authenticated(
            attribute, user.send(attribute))).to eq(user)
        end        
      end
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
    
    [:activation, :password_reset].each do |email_type|
      it "sets send time" do
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