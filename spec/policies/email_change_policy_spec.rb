require 'rails_helper'

describe EmailChangePolicy do
  subject { described_class.new(current_user, email_change) }
  let(:email_change) { Object.new }

  context "when the user is not signed in" do
    let(:current_user) { nil }

    it { is_expected.to_not permit(:new)     }
    it { is_expected.to_not permit(:create)  }
    it { is_expected.to_not permit(:destroy) }
  end

  context "when the user is signed in" do
    context "and has a pending email change request" do
      let(:current_user) { FactoryGirl.build_stubbed(:user, :email_change_pending) }

      it { is_expected.to permit(:new)     }
      it { is_expected.to permit(:create)  }
      it { is_expected.to permit(:destroy) }
    end

    context "and does not have a pending email change request" do
      let(:current_user) { FactoryGirl.build_stubbed(:user) }

      it { is_expected.to     permit(:new)     }
      it { is_expected.to     permit(:create)  }
      it { is_expected.to_not permit(:destroy) }
    end
  end
end