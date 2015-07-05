require 'rails_helper'

describe UserPolicy do
  subject { described_class.new(current_user, user) }
  let(:user) { FactoryGirl.build_stubbed(:user) }

  context "when user is not signed in" do
    let(:current_user) { nil }

    it { is_expected.to     permit(:new)      }
    it { is_expected.to     permit(:create)   }
    it { is_expected.to     permit(:validate) }
    it { is_expected.to_not permit(:show)     }
  end

  context "when user is signed in" do
    let(:current_user) { FactoryGirl.build_stubbed(:user) }

    it { is_expected.to_not permit(:new)      }
    it { is_expected.to_not permit(:create)   }
    it { is_expected.to_not permit(:validate) }
    it { is_expected.to     permit(:show)     }

    # context "as another user" do
    #   it { is_expected.to_not permit(:show) }
    # end

    # context "as target user" do
    #   let(:current_user) { user }

    #   it { is_expected.to permit(:show) }
    # end
  end
end