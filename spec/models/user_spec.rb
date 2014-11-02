require 'rails_helper'

describe User do
  
  subject(:user) { User.new(name: 'First Last',
                            email: 'first.last@example.com',
                            password: 'qwerty123',
                            password_confirmation: 'qwerty123') }

  it { is_expected.to respond_to :name }
  it { is_expected.to respond_to :email }
  it { is_expected.to respond_to :password_digest }
  it { is_expected.to respond_to :password }
  it { is_expected.to respond_to :password_confirmation }
  it { is_expected.to respond_to :authenticate }

  it { is_expected.to be_valid }

  context "when name is blank" do
    before { user.name = ' ' }
    it { is_expected.to be_invalid }
  end

  context "when name is too long" do
    before { user.name = 'a' * 51 }
    it { is_expected.to be_invalid }
  end

  context "when email is blank" do
    before { user.email = ' ' }
    it { is_expected.to be_invalid }
  end

  context "when email is too long" do
    before { user.email = "#{'a' * 39}@example.com" }
    it { is_expected.to be_invalid}
  end

  context "when email is already taken" do
    let(:user_with_same_email) { user.dup }
    before do
      user_with_same_email.email = user.email.swapcase
      user_with_same_email.save
    end
    it { is_expected.to be_invalid }
  end

  context "when email format is invalid" do
    let(:addresses) { %w[ .starts-with-dot@example.com double..dot@test.org
                          double.dot@test..org no_at_sign.net double@at@sign.com
                          without@dot,com ends+with@dot. ] }
    it "should be invalid" do
      addresses.each do |invalid_address|
        user.email = invalid_address
        expect(user).to be_invalid
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
    before { user.password = user.password_confirmation = ' ' * 6 }
    it { is_expected.to be_invalid }
  end

  context "when password is too short" do
    before { user.password = user.password_confirmation = 'a' * 5 }
    it { is_expected.to be_invalid }
  end

  context "when password is too long" do
    before { user.password = user.password_confirmation = 'a' * 31 }
    it { is_expected.to be_invalid }
  end

  context "when password confirmation is empty" do
    before { user.password_confirmation = '' }
    it { is_expected.to be_invalid }
  end

  context "when password and confirmation do no match" do
    before { user.password = 'mismatch' }
    it { is_expected.to be_invalid }
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
end