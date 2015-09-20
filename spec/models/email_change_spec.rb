require 'rails_helper'

describe EmailChange do
  let(:user)  { FactoryGirl.create :user }
  let(:new_email) { 'new.email@example.com' }
  let(:new_email_confirmation) { new_email }
  let(:current_password) { user.password }

  subject(:email_change) {
    EmailChange.new(
      new_email: new_email,
      new_email_confirmation: new_email_confirmation,
      current_password: current_password
    )
  }

  before { subject.user = user }

  it { is_expected.to be_valid }

  describe "with a new email that" do
    context "is blank" do
      let(:new_email) { ' ' }

      it { is_expected.to have_errors(1) }
    end

    context "is too long" do
      let(:new_email) { ('a' * 49).insert(-10, '@').insert(-4, '.') }

      it { is_expected.to have_errors(1) }
    end

    context "does not match the confirmation" do
      before { subject.new_email = 'mismatched@email.com' }

      it { is_expected.to have_errors(1) }
    end
    
    context "is of invalid format" do
      it "should be invalid and have 1 error" do
        INVALID_EMAILS.each do |email|
          subject.new_email_confirmation = subject.new_email = email
          expect(subject).to have_errors(1)
        end
      end
    end

    context "is of valid format" do
      it "should be valid" do
        VALID_EMAILS.each do |email|
          subject.new_email_confirmation = subject.new_email = email
          expect(subject).to be_valid
        end
      end
    end

    context "is already taken" do
      let(:another_user) { FactoryGirl.create :user }
      before { subject.new_email_confirmation = subject.new_email = another_user.email.upcase }

      it "should be invalid and have 1 error" do
        expect(subject).to have_errors(1)
        expect(subject.errors.added? :new_email, :taken).to eq(true)
      end

      it { is_expected.to have_errors(1) }
    end

    context "is the same as the original" do      
      before { subject.new_email_confirmation = subject.new_email = user.email.upcase }

      it "should be invalid and have 1 error" do
        expect(subject).to have_errors(1)
        expect(subject.errors.added? :new_email, :unchanged).to eq(true)
      end
    end
  end

  describe "with a current password that" do
    context "is incorrect" do
      let(:current_password) { 'incorrect' }

      it { is_expected.to have_errors(1) }
    end
  end

  describe "the new email and its confirmation" do
    let(:mixed_case_email)       { 'MIXED.case@email.COM' }
    let(:new_email)              { mixed_case_email.dup }
    let(:new_email_confirmation) { mixed_case_email.dup }
    before { subject.valid? }

    it "get downcased before validation" do      
      expect(subject.new_email_confirmation).to eq(subject.new_email).and eq(mixed_case_email.downcase)
    end
  end
end