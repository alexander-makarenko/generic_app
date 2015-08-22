require 'rails_helper'

describe EmailConfirmationPolicy do
  subject { described_class.new(current_user, email_confirmation) }
  let(:email_confirmation) { Object.new }

  context "when the user is not signed in" do
    let(:current_user) { nil }

    it { is_expected.to_not permit(:create) }
    it { is_expected.to     permit(:edit) }
  end

  context "when the user is signed in" do
    context "and their email is not confirmed" do
      let(:current_user) { FactoryGirl.build_stubbed(:user) }

      it { is_expected.to permit(:create) }
      it { is_expected.to permit(:edit)   }
    end

    context "and their email is confirmed" do
      let(:current_user) { FactoryGirl.build_stubbed(:user, :email_confirmed) }
      
      it { is_expected.to_not permit(:create) }
      it { is_expected.to_not permit(:edit)   }
    end
  end
end