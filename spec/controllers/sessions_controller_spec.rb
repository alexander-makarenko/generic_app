require 'rails_helper'

describe SessionsController do
  describe "authorization" do
    let(:user) { FactoryGirl.create(:user, :email_confirmed) }
    let(:create_params) { Hash[ email: '', password: '' ] }

    context "when the user is not signed in" do
      before { bypass_rescue }

      it "permits GET to #new" do
        expect { get :new }.to be_permitted
      end

      it "permits POST to #create" do
        expect { post :create, create_params }.to be_permitted
      end

      it "forbids DELETE to #destroy" do
        expect { delete :destroy }.to_not be_permitted
      end
    end

    context "when the user is signed in" do
      before do
        bypass_rescue
        sign_in_as(user, no_capybara: true)
      end

      it "forbids GET to #new" do
        expect { get :new }.to_not be_permitted
      end

      it "forbids POST to #create" do
        expect { post :create, create_params }.to_not be_permitted
      end

      it "permits DELETE to #destroy" do
        expect { delete :destroy }.to be_permitted
      end
    end

    describe "exception handler" do
      controller(SessionsController) do
        def index
          raise Pundit::NotAuthorizedError
        end
      end

      before { get :index }

      it "does not set a flash" do
        expect(flash[:danger]).to be_nil
      end

      it "redirects to the home page" do
        expect(response).to redirect_to root_path
      end
    end
  end
end