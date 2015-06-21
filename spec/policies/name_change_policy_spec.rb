require 'rails_helper'

describe NameChangePolicy do
  subject { described_class.new(current_user, name_change) }
  let(:name_change) { Object.new }

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