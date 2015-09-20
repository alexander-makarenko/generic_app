require 'rails_helper'

describe EmailChangesController do
  describe "authorization" do
    let(:user) { FactoryGirl.create(:user, :email_change_pending) }

    before { bypass_rescue }

    context "when the user is not signed in" do
      it "forbids GET to #new" do
        expect { get :new }.to_not be_permitted
      end

      it "forbids POST to #create" do
        expect { post :create }.to_not be_permitted
      end

      it "forbids DELETE to #destroy" do
        expect { delete :destroy }.to_not be_permitted
      end
    end

    context "when the user is signed in" do
      before { sign_in_as(user, no_capybara: true) }

      context "and has a pending email change request" do
        it "permits GET to #new" do
          expect { get :new }.to be_permitted
        end

        it "permits POST to #create" do
          expect { post :create }.to be_permitted
        end

        it "permits DELETE to #destroy" do
          expect { delete :destroy }.to be_permitted
        end
      end

      context "and does not have a pending email change request" do
        let(:user) { FactoryGirl.create(:user) }

        it "permits GET to #new" do
          expect { get :new }.to be_permitted
        end

        it "permits POST to #create" do
          expect { post :create }.to be_permitted
        end

        it "forbids DELETE to #destroy" do
          expect { delete :destroy }.to_not be_permitted
        end
      end
    end
  end
end