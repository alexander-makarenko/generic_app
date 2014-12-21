require 'rails_helper'

describe User do
  let(:name)     { 'First Last' }
  let(:email)    { 'first.last@example.com' }
  let(:password) { 'qwerty123' }

  subject(:user) { User.new(
    name: name,
    email: email,
    password: password,
    password_confirmation: password) }

  [ :name,
    :email,
    :password_digest,
    :password,
    :password_confirmation,
    :authenticated,
    :auth_digest,
    :activation_token,
    :activation_digest,
    :activation_email_sent_at,
    :activated,
    :activated_at,
    :password_reset_token,
    :password_reset_digest,
    :password_reset_email_sent_at    
  ].each do |method|
    it { is_expected.to respond_to method }
  end

  it { is_expected.to be_valid }
  it { is_expected.to_not be_activated }

  describe "with name that" do
    context "is blank" do
      let(:name) { ' ' }

      specify "is invalid and has 1 error" do
        expect(user).to be_invalid
        expect(user.errors.count).to eq(1)
      end
    end

    context "is too long" do
      let(:name) { 'a' * 51 }

      specify "is invalid and has 1 error" do
        expect(user).to be_invalid
        expect(user.errors.count).to eq(1)
      end
    end
  end

  describe "with email that" do
    context "is blank" do
      let(:email) { ' ' }

      specify "is invalid and has 1 error" do
        expect(user).to be_invalid
        expect(user.errors.count).to eq(1)
      end
    end

    context "is too long" do
      let(:email) { "#{'a' * 39}@example.com" }

      specify "is invalid and has 1 error" do
        expect(user).to be_invalid
        expect(user.errors.count).to eq(1)
      end
    end

    context "is already taken" do
      let(:user_with_same_email) { user.dup }
      before do
        user_with_same_email.email = user.email.swapcase
        user_with_same_email.save
      end

      specify "is invalid and has 1 error" do
        expect(user).to be_invalid
        expect(user.errors.count).to eq(1)
      end
    end

    context "is of invalid format" do
      let(:addresses) { %w[
        .starts-with-dot@example.com double..dot@test.org
        double.dot@test..org no_at_sign.net double@at@sign.com
        without@dot,com ends+with@dot. ] }
      
      specify "is invalid and has 1 error" do
        addresses.each do |invalid_address|
          user.email = invalid_address
          expect(user).to be_invalid
          expect(user.errors.count).to eq(1)
        end
      end
    end

    context "is of valid format" do
      let(:addresses) { %w[
        user@example.com first.last@somewhere.COM
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
        
        specify "is invalid and has 1 error" do
          expect(user).to be_invalid
          expect(user.errors.count).to eq(1)
        end
      end

      context "on update" do
        subject(:persisted_user) { User.find_by(email: user.email) }
        before do
          user.save
          persisted_user.password = ' ' * 6
        end        

        specify "is invalid and has 1 error" do
          expect(persisted_user).to be_invalid
          expect(persisted_user.errors.count).to eq(1)
        end
      end
    end

    context "is too short" do
      let(:password) { 'a' * 5 }

      specify "is invalid and has 1 error" do
        expect(user).to be_invalid
        expect(user.errors.count).to eq(1)
      end
    end

    context "is too long" do
      let(:password) { 'a' * 31 }

      specify "is invalid and has 1 error" do
        expect(user).to be_invalid
        expect(user.errors.count).to eq(1)
      end
    end

    context "does not match confirmation" do
      before { user.password = 'mismatch' }

      specify "is invalid and has 1 error" do
        expect(user).to be_invalid
        expect(user.errors.count).to eq(1)
      end
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

  describe "#authenticated" do
    let(:found_user) { User.find_by(email: user.email) }
    before { user.save }

    accepted_attributes = [:password, :activation_token, :password_reset_token]
    accepted_attributes.each do |attribute|
      context "with #{attribute}" do
        context "that is incorrect" do
          it "returns false" do
            expect(found_user.authenticated(
              attribute, 'incorrect')).to eq(false)
          end
        end

        context "that is correct" do
          it "returns user" do
            expect(found_user.authenticated(
              attribute, user.send(attribute))).to eq(user)
          end
        end
      end
    end
  end

  describe "#send_link" do
    [:activation, :password_reset].each do |link_type|
      it "sets email_sent_at time" do
        expect { user.send_link(link_type) }.to change {
          user.send("#{link_type}_email_sent_at")
        }.from(nil).to(ActiveSupport::TimeWithZone)
      end

      context "when #{link_type}_token is blank" do
        let(:found_user) { User.find_by(email: user.email) }
        before { user.save }

        it "generates new token" do
          expect { found_user.send_link(link_type) }.to change {
            found_user.send("#{link_type}_token")
          }.from(nil).to(String)
        end

        it "updates #{link_type}_digest" do
          expect { found_user.send_link(link_type) }.to change(
            found_user.reload, "#{link_type}_digest")
        end
      end
    end
  end
end