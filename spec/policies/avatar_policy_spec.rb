require 'rails_helper'

describe AvatarPolicy do
  subject { described_class.new(current_user, avatar) }
  let(:avatar) { Object.new }

  context "when the user is not signed in" do
    let(:current_user) { nil }

    it { is_expected.to_not permit(:create)  }
    it { is_expected.to_not permit(:destroy) }
  end

  context "when the user is signed in" do
    let(:current_user) { FactoryGirl.build_stubbed(:user) }
    
    it { is_expected.to permit(:create)  }
    it { is_expected.to permit(:destroy) }
  end
end