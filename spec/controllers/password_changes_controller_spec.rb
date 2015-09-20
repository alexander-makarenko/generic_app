require 'rails_helper'

describe PasswordChangesController do
  describe "#create" do
    let(:user) { FactoryGirl.create(:user) }
    let(:params) do
      { password_change: { current_password: user.password, new_password: new_password,
          new_password_confirmation: new_password } }
    end

    subject { post :create, params }

    before { sign_in_as(user, no_capybara: true) }

    context "with invalid data" do
      let(:new_password) { '' }

      it "does not update the user's password" do
        expect { subject }.to_not change { user.reload.password_digest }
      end
    end

    context "with valid data" do
      let(:new_password) { 'new_password' }

      it "updates the user's password" do
        expect { subject }.to change { user.reload.password_digest }
      end
    end
  end

  describe "authorization" do
    let(:user) { FactoryGirl.create(:user, :email_confirmed) }
    
    before { bypass_rescue }

    context "when the user is not signed in" do
      it "forbids GET to #new" do
        expect { get :new }.to_not be_permitted
      end

      it "forbids POST to #create" do
        expect { post :create }.to_not be_permitted
      end
    end

    context "when the user is signed in" do
      before { sign_in_as(user, no_capybara: true) }

      it "permits GET to #new" do
        expect { get :new }.to be_permitted
      end

      it "permits POST to #create" do
        expect { post :create }.to be_permitted
      end
    end
  end
end