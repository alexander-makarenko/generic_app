require 'rails_helper'

describe PasswordReset do
  let(:user)  { FactoryGirl.create(:user) }
  let(:email) { user.email }

  subject(:password_reset) { PasswordReset.new(email: email) }

  it { is_expected.to be_valid }

  describe "with email that" do
    context "is blank", expect_errors: 1 do
      let(:email) { ' ' }
    end

    context "is too long", expect_errors: 1 do
      let(:email) { ('a' * 49).insert(-10, '@').insert(-4, '.') }
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

      context "when user with such email doesn't exist" do
        valid_addresses.each do |address|
          describe "#{address}" do
            before { subject.email = address }
            it { is_expected.to_not be_valid }
          end
        end
      end

      context "when user with such email exists" do
        valid_addresses.each do |address|
          describe "#{address}" do
            before do
              FactoryGirl.create(:user, email: address)
              subject.email = address.upcase
            end

            it { is_expected.to be_valid }
          end
        end
      end
    end
  end

  describe "user attribute after validation" do
    before { subject.valid? }

    context "when self is valid" do
      it "references User instance corresponding to value of self's email attribute" do
        expect(subject).to have_attributes(user: user)
      end
    end

    context "when self is invalid" do
      before do
        subject.email = 'unknown@user.com'
        subject.valid?
      end

      it "is nil" do
        expect(subject).to have_attributes(user: nil)
      end
    end
  end

  describe "#email=" do
    let(:mixed_case_email) { 'first.LAST@example.COM' }
    before { subject.email = mixed_case_email }

    it "downcases value before assigning" do
      expect(subject).to have_attributes(email: mixed_case_email.downcase)
    end
  end
end