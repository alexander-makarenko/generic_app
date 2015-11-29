require 'rails_helper'

describe UserPolicy do
  subject { described_class.new(current_user, user) }
  let(:user) { FactoryGirl.build_stubbed(:user) }

  context "when the user is not signed in" do
    let(:current_user) { nil }

    it { is_expected.to     permit(:new)      }
    it { is_expected.to     permit(:create)   }
    it { is_expected.to     permit(:validate) }
    it { is_expected.to_not permit(:show)     }
    it { is_expected.to_not permit(:index)     }
  end

  context "when the user is signed in" do
    context "as a regular user" do
      let(:current_user) { FactoryGirl.build_stubbed(:user) }

      it { is_expected.to_not permit(:new)      }
      it { is_expected.to_not permit(:create)   }
      it { is_expected.to_not permit(:validate) }
      it { is_expected.to     permit(:show)     }
      it { is_expected.to_not permit(:index)    }
    end

    context "as an admin user" do
      let(:current_user) { FactoryGirl.build_stubbed(:user, :admin) }

      it { is_expected.to_not permit(:new)      }
      it { is_expected.to_not permit(:create)   }
      it { is_expected.to_not permit(:validate) }
      it { is_expected.to     permit(:show)     }
      it { is_expected.to     permit(:index)    }
    end
  end
end