require 'rails_helper'

describe PasswordResetPolicy do
  subject { described_class.new(current_user, password_reset) }
  let(:current_user)   { nil }
  let(:password_reset) { Object.new }

  it { is_expected.to permit(:new)    }
  it { is_expected.to permit(:create) }
  it { is_expected.to permit(:edit)   }
  it { is_expected.to permit(:update) }
end