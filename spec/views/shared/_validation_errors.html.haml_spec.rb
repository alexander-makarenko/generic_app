require "rails_helper"

describe "shared/_validation_errors" do
  let(:user) { FactoryGirl.build(:user) }

  def render_partial
    render 'shared/validation_errors', obj: user
  end

  before { I18n.locale = :ru }

  context "when a provided object is valid" do
    before { render_partial }

    it "renders nothing" do
      expect(rendered).to be_empty
    end
  end

  context "when a provided object is invalid" do
    let(:error) { 'is not valid' }
    
    context "and has multiple error messages" do
      before do
        user.errors.add(:email, error)
        user.errors.add(:password, error.upcase)
        render_partial
      end

      it "renders them all" do
        expect(rendered).to match(error).and match(error.upcase)
      end
    end

    context "and has duplicate error messages" do
      let(:times_error_is_rendered) { rendered.scan(error).size }

      before do
        3.times { user.errors.add(:email, error) }
        render_partial
      end

      it "renders each message only once" do
        expect(times_error_is_rendered).to eq 1
      end
    end

    context "and has an error message that contain uppercase letters" do
      before do
        user.errors.add(:email, error.upcase)
        render_partial
      end

      it "capitalizes its first letter, not changing the case of the other letters" do
        expect(rendered).to match /[[:upper:]].+#{error.upcase}/
      end
    end
  end
end