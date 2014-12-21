require 'rails_helper'

describe SessionPolicy do
  subject { described_class.new(current_user, session) }
  let(:session) { Object.new }

  context "when user is not signed in" do
    let(:current_user) { nil }

    it { is_expected.to     permit(:new)     }
    it { is_expected.to     permit(:create)  }
    it { is_expected.to_not permit(:destroy) }
  end

  context "when user is signed in" do
    let(:current_user) { FactoryGirl.build_stubbed(:user) }

    it { is_expected.to_not permit(:new)     }
    it { is_expected.to_not permit(:create)  }
    it { is_expected.to     permit(:destroy) }
  end
end