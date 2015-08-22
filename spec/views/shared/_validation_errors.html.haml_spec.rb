require "rails_helper"

describe "shared/_validation_errors" do
  before do
    I18n.locale = :ru
    user.valid?
    render 'shared/validation_errors', obj: user
  end

  context "when a provided object is valid" do
    let(:user) { FactoryGirl.build(:user) }

    it "renders nothing" do
      expect(rendered).to be_empty
    end
  end

  context "when a provided object is invalid" do
    let(:user)   { FactoryGirl.build(:user, :invalid) }
    let(:errors) { user.errors.full_messages }

    it "renders all error messages" do
      errors.each do |error|
        expect(rendered).to match /#{error}/i
      end
    end

    context "when there are duplicate error messages" do
      let(:message) { 'has some error' }
      let(:times_error_is_rendered) { rendered.scan(message).size }

      before do
        3.times { user.errors.add(:first_name, message) }
        render 'shared/validation_errors', obj: user
      end

      it "renders each of them only once" do
        expect(times_error_is_rendered).to eq(1)
      end
    end

    it "capitalizes individual error messages" do
      capitalized_string_regex = /\A[[:upper:]][^[:upper:]]+/
      errors.each do |error|
        rendered_error = rendered.match(/#{error}/i).to_s
        expect(rendered_error).to match(capitalized_string_regex)
      end
    end
  end
end