require 'rails_helper'

describe AvatarsController do
  describe "authorization" do
    let(:user) { FactoryGirl.create(:user) }

    before { bypass_rescue }

    context "when the user is not signed in" do      
      it "forbids POST to #create" do
        expect { post :create }.to_not be_permitted
      end

      it "forbids DELETE to #destroy" do
        expect { delete :destroy }.to_not be_permitted
      end
    end

    context "when the user is signed in" do
      before { sign_in_as(user, no_capybara: true) }

      context "and has the default profile image" do
        it "permits POST to #create" do
          expect { post :create }.to be_permitted
        end

        it "permits DELETE to #destroy" do
          expect { delete :destroy }.to_not be_permitted
        end
      end

      context "and has a custom profile image" do
        let(:user) { FactoryGirl.create(:user, :photo_uploaded) }

        it "permits POST to #create" do
          expect { post :create }.to be_permitted
        end

        it "permits DELETE to #destroy" do
          expect { delete :destroy }.to be_permitted
        end
      end      
    end
  end
end
