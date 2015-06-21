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

  before { password_change.user = user }

  it { is_expected.to be_valid }

  describe "with incorrect current password", expect_errors: 1 do
    let(:current_password) { 'incorrect' }
  end

  describe "with new password that" do
    context "is blank", expect_errors: 1 do
      let(:new_password) { ' ' }
    end

    context "is too short", expect_errors: 1 do
      let(:new_password) { 'a' * 5 }
    end

    context "is too long", expect_errors: 1 do
      let(:new_password) { 'a' * 31 }
    end
  end

  describe "with incorrect confirmation of new password", expect_errors: 1 do
    let(:new_password_confirmation) { 'mismatch' }
  end
end