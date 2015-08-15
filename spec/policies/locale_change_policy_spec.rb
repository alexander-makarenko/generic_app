require 'rails_helper'

describe LocaleChangePolicy do
  subject { described_class.new(current_user, locale_change) }
  let(:current_user)  { nil }
  let(:locale_change) { Object.new }

  it { is_expected.to permit(:create) }
end