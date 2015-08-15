require 'rails_helper'

describe PasswordReset do
  let(:user)  { FactoryGirl.create(:user) }
  let(:email) { user.email }
  subject(:password_reset) { PasswordReset.new(email: email) }

  it { is_expected.to be_valid }

  describe "with an email that" do
    context "is blank", expect_errors: 1 do
      let(:email) { ' ' }
    end

    context "is too long", expect_errors: 1 do
      let(:email) { ('a' * 49).insert(-10, '@').insert(-4, '.') }
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
      context "but does not belong to any existing user" do
        it "is invalid" do
          VALID_EMAILS.each do |email|
            subject.email = email
            expect(subject).to_not be_valid
          end
        end
      end

      context "and belongs to an existing user" do
        it "is valid" do
          VALID_EMAILS.each do |email|
            FactoryGirl.create(:user, email: email)
            subject.email = email.upcase
            expect(subject).to be_valid
          end 
        end
      end
    end
  end

  describe "has a user attribute that after validation" do
    before { subject.valid? }

    context "when self is valid" do
      it "references a User instance corresponding to the value of self's email attribute" do
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

    it "downcases the value before assigning" do
      expect(subject).to have_attributes(email: mixed_case_email.downcase)
    end
  end
end