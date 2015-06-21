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

  describe "with new first name that" do
    context "is blank", expect_errors: 1 do
      let(:new_first_name) { ' ' }
    end

    context "is too long", expect_errors: 1 do
      let(:new_first_name) { 'a' * 31 }
    end
  end

  describe "with new last name that" do
    context "is blank", expect_errors: 1 do
      let(:new_last_name) { ' ' }
    end

    context "is too long", expect_errors: 1 do
      let(:new_last_name) { 'a' * 31 }
    end
  end
end