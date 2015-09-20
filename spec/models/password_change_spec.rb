require 'rails_helper'

describe PasswordChange do
  let(:user) { FactoryGirl.create(:user) }
  let(:current_password) { user.password }
  let(:new_password) { 'qwerty123' }
  let(:new_password_confirmation) { new_password }

  subject(:password_change) {
    PasswordChange.new(
      current_password: current_password,
      new_password: new_password,
      new_password_confirmation: new_password_confirmation
    )
  }

  before { subject.user = user }

  it { is_expected.to be_valid }

  describe "with an incorrect current password" do
    let(:current_password) { 'incorrect' }
    it { is_expected.to have_errors(1) }
  end

  describe "with a new password that" do
    context "is blank" do
      let(:new_password) { ' ' }
      it { is_expected.to have_errors(1) }
    end

    context "is too short" do
      let(:new_password) { 'a' * 5 }
      it { is_expected.to have_errors(1) }
    end

    context "is too long" do
      let(:new_password) { 'a' * 31 }
      it { is_expected.to have_errors(1) }
    end
  end

  describe "with an incorrect confirmation of the new password" do
    let(:new_password_confirmation) { 'mismatch' }
    it { is_expected.to have_errors(1) }
  end
end