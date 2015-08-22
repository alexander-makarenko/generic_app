require 'rails_helper'

describe EmailConfirmationsController do
  describe "authorization" do
    let(:user) { FactoryGirl.create(:user) }
    let(:edit_params) { Hash[ hashed_email: 'foo', token: 'bar' ] }

    context "when the user is not signed in" do
      before { bypass_rescue }

      it "forbids POST to #create" do
        expect { post :create }.to_not be_permitted
      end

      it "permits GET to #edit" do
        expect { get :edit, edit_params }.to be_permitted
      end
    end

    context "when the user is signed in" do
      before do
        bypass_rescue
        sign_in_as(user, no_capybara: true)
      end

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

    describe "exception handler" do
      controller(EmailConfirmationsController) do
        def index
          raise Pundit::NotAuthorizedError
        end
      end
      
      before { get :index }

      it "sets a flash" do
        expect(flash[:danger]).to_not be_nil
      end

      it "redirects to the home page" do
        expect(response).to redirect_to root_path
      end
    end
  end
end