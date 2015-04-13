require 'rails_helper'

describe PasswordChangePolicy do
  subject { described_class.new(current_user, password_change) }
  let(:password_change) { Object.new }

  context "when user is not signed in" do
    let(:current_user) { nil }

    it { is_expected.to_not permit(:new)    }
    it { is_expected.to_not permit(:create) }
  end

  context "when user is signed in" do
    let(:current_user) { FactoryGirl.build_stubbed(:user) }

    it { is_expected.to permit(:new)    }
    it { is_expected.to permit(:create) }
  end
end