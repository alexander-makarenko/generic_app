require 'rails_helper'

describe PasswordChange do
  let(:user) { FactoryGirl.create(:user) }
  let(:current_password) { user.password }
  let(:new_password) { 'qwerty123' }
  let(:new_password_confirmation) { new_password }

  subject(:password_change) { PasswordChange.new(
    current_password: current_password,
    new_password: new_password,
    new_password_confirmation: new_password_confirmation
  ) }

  before { password_change.user = user }

  it { is_expected.to be_valid }

  describe "responds to" do
    known_methods = [
      :current_password,
      :new_password,
      :new_password_confirmation
    ]

    known_methods.each do |method|
      it %Q|"#{method}" method| do
        expect(subject).to respond_to method
      end
    end
  end

  describe "with incorrect current password" do
    let(:current_password) { 'incorrect' }
    include_examples "is invalid and has errors", 1
  end

  describe "with new password that" do
    context "is blank" do
      let(:new_password) { ' ' }
      include_examples "is invalid and has errors", 1
    end

    context "is too short" do
      let(:new_password) { 'a' * 5 }
      include_examples "is invalid and has errors", 1
    end

    context "is too long" do
      let(:new_password) { 'a' * 31 }
      include_examples "is invalid and has errors", 1
    end
  end

  describe "with incorrect confirmation of new password" do
    let(:new_password_confirmation) { 'mismatch' }
    include_examples "is invalid and has errors", 1
  end
end