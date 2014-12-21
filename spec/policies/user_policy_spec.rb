require 'rails_helper'

describe UserPolicy do
  subject { described_class.new(current_user, user) }
  let(:user) { FactoryGirl.build_stubbed(:user) }

  context "when user is not signed in" do
    let(:current_user) { nil }

    it { is_expected.to     permit(:new)    }
    it { is_expected.to     permit(:create) }
    it { is_expected.to_not permit(:edit)   }
    it { is_expected.to_not permit(:update) }
  end

  context "when user is signed in" do
    let(:current_user) { FactoryGirl.build_stubbed(:user) }

    it { is_expected.to_not permit(:new)    }
    it { is_expected.to_not permit(:create) }

    context "as another user" do
      it { is_expected.to_not permit(:edit)   }
      it { is_expected.to_not permit(:update) }
    end

    context "as target user" do
      let(:current_user) { user }

      it { is_expected.to permit(:edit)   }
      it { is_expected.to permit(:update) }
    end
  end
end