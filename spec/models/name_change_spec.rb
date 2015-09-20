require 'rails_helper'

describe NameChange do
  let(:new_first_name) { 'First' }
  let(:new_last_name)  { 'Last' }

  subject(:name_change) {
    NameChange.new(
      new_first_name: new_first_name,
      new_last_name: new_last_name
    )
  }

  it { is_expected.to be_valid }

  describe "with a new first name that" do
    context "is blank" do
      let(:new_first_name) { ' ' }
      it { is_expected.to have_errors(1) }
    end

    context "is too long" do
      let(:new_first_name) { 'a' * 31 }
      it { is_expected.to have_errors(1) }
    end
  end

  describe "with a new last name that" do
    context "is blank" do
      let(:new_last_name) { ' ' }
      it { is_expected.to have_errors(1) }
    end

    context "is too long" do
      let(:new_last_name) { 'a' * 31 }
      it { is_expected.to have_errors(1) }
    end
  end
end