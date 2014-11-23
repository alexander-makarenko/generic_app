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

  it { is_expected.to respond_to :name }
  it { is_expected.to respond_to :email }
  it { is_expected.to respond_to :password_digest }
  it { is_expected.to respond_to :password }
  it { is_expected.to respond_to :password_confirmation }
  it { is_expected.to respond_to :authenticate }
  it { is_expected.to respond_to :auth_digest }
  it { is_expected.to respond_to :activation_token }
  it { is_expected.to respond_to :activation_digest }
  it { is_expected.to respond_to :activation_email_sent_at }
  it { is_expected.to respond_to :activated }
  it { is_expected.to respond_to :activated_at }

  it { is_expected.to be_valid }
  it { is_expected.to_not be_activated }

  context "when name is blank" do
    before { user.name = ' ' }
    it "should be invalid and have 1 error" do
      expect(user).to be_invalid
      expect(user.errors.count).to eq(1)
    end
  end

  context "when name is too long" do
    before { user.name = 'a' * 51 }
    it "should be invalid and have 1 error" do
      expect(user).to be_invalid
      expect(user.errors.count).to eq(1)
    end
  end

  context "when email is blank" do
    before { user.email = ' ' }
    it "should be invalid and have 1 error" do
      expect(user).to be_invalid
      expect(user.errors.count).to eq(1)
    end
  end

  context "when email is too long" do
    before { user.email = "#{'a' * 39}@example.com" }
    it "should be invalid and have 1 error" do
      expect(user).to be_invalid
      expect(user.errors.count).to eq(1)
    end
  end

  context "when email is already taken" do
    let(:user_with_same_email) { user.dup }
    before do
      user_with_same_email.email = user.email.swapcase
      user_with_same_email.save
    end
    it "should be invalid and have 1 error" do
      expect(user).to be_invalid
      expect(user.errors.count).to eq(1)
    end
  end

  context "when email format is invalid" do
    let(:addresses) { %w[ .starts-with-dot@example.com double..dot@test.org
                          double.dot@test..org no_at_sign.net double@at@sign.com
                          without@dot,com ends+with@dot. ] }
    it "should be invalid and have 1 error" do
      addresses.each do |invalid_address|
        user.email = invalid_address
        expect(user).to be_invalid
        expect(user.errors.count).to eq(1)
      end
    end
  end

  context "when email format is valid" do
    let(:addresses) { %w[ user@example.com first.last@somewhere.COM
                          fir5t_la5t@somewhe.re FIRST+LAST@s.omwhe.re ] }
    it "should be valid" do
      addresses.each do |valid_address|
        user.email = valid_address
        expect(user).to be_valid
      end
    end
  end

  context "when email is mixed-case" do
    let(:mixed_case_email) { 'first.LAST@example.COM' }
          
    it "should be saved with email in lower case" do
      user.email = mixed_case_email.dup
      user.save
      expect(user.reload.email).to eq(mixed_case_email.downcase)
    end
  end

  context "when password is blank" do

    context "on create" do
      let(:password) { ' ' * 6 }
      
      it "should be invalid and have 1 error" do
        expect(user).to be_invalid
        expect(user.errors.count).to eq(1)
      end
    end

    context "on update" do
      before { user.save }
      let(:persisted_user) { User.find_by(email: user.email) }

      it "should be invalid and have 1 error" do
        persisted_user.password = ' ' * 6
        expect(persisted_user).to be_invalid
        expect(persisted_user.errors.count).to eq(1)
      end
    end
  end

  context "when password is too short" do
    before { user.password = user.password_confirmation = 'a' * 5 }
    it "should be invalid and have 1 error" do
      expect(user).to be_invalid
      expect(user.errors.count).to eq(1)
    end
  end

  context "when password is too long" do
    before { user.password = user.password_confirmation = 'a' * 31 }
    it "should be invalid and have 1 error" do
      expect(user).to be_invalid
      expect(user.errors.count).to eq(1)
    end
  end

  context "when password and confirmation do no match" do
    before { user.password = 'mismatch' }
    it "should be invalid and have 1 error" do
      expect(user).to be_invalid
      expect(user.errors.count).to eq(1)
    end
  end

  describe "#authenticate" do
    before { user.save }
    let(:found_user) { User.find_by(email: user.email) }

    context "with invalid password" do
      it "should return false" do
        expect(found_user.authenticate('incorrect')).to eq(false)
      end
    end

    context "with valid password" do
      it "should return the user" do
        expect(found_user.authenticate(user.password)).to eq(user)
      end
    end
  end

  context "when created" do
    before { user.save }
    let(:persisted_user) { User.find_by(email: user.email) }
  
    it "is assigned non-empty auth digest" do
      expect(persisted_user.auth_digest).to_not be_blank
    end

    it "is assigned non-empty activation digest" do
      expect(persisted_user.activation_digest).to_not be_blank
    end
  end

  describe "#send_activation_link" do
    
    it "sets activation_email_sent_at time" do
      expect { user.send_activation_link }.to change {
        user.activation_email_sent_at
      }.from(nil).to(ActiveSupport::TimeWithZone)
    end

    context "when activation token is blank" do
      before { user.save }
      let(:found_user) { User.find_by(email: user.email) }
            
      it "generates new activation token" do
        expect { found_user.send_activation_link }.to change {
          found_user.activation_token
        }.from(nil).to(String)
      end

      it "updates activation digest" do
        expect { found_user.send_activation_link }.to change(
          found_user.reload, :activation_digest
        )
      end
    end
  end
end