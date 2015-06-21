require 'rails_helper'

describe EmailConfirmationsController do
  describe "authorization" do
    let(:user) { FactoryGirl.create(:user) }
    let(:edit_params) { Hash[ hashed_email: 'foo', token: 'bar' ] }
    before { bypass_rescue }

    context "when user is not signed in" do
      it "forbids POST to #create" do
        expect { post :create }.to_not be_permitted
      end

      it "permits GET to #edit" do
        expect { get :edit, edit_params }.to be_permitted
      end
    end

    context "when user is signed in" do
      before { sign_in_as(user, no_capybara: true) }

      context "and their email is not confirmed" do
        it "permits POST to #create" do
          expect { post :create }.to be_permitted
        end

        it "permits GET to #edit" do
          expect { get :edit, edit_params }.to be_permitted
        end
      end

      context "and their email is confirmed" do
        let(:user) { FactoryGirl.create(:user, :email_confirmed) }

        it "forbids POST to #create" do
          expect { post :create }.to_not be_permitted
        end

        it "forbids GET to #edit" do
          expect { get :edit, edit_params }.to_not be_permitted
        end
      end
    end
  end
end