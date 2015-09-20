require 'rails_helper'

describe EmailConfirmationsController do
  describe "#edit" do
    let(:user) { FactoryGirl.create(:user, :email_confirmation_sent) }
    let(:hashed_email) { User.digest(user.email) }
    let(:token) { user.email_confirmation_token }
    let(:params) { { hashed_email: hashed_email, token: token } }
    
    subject { get :edit, params }

    context "with valid hashed email and token" do
      it "changes the user's email confirmation status" do
        expect { subject }.to change {
          user.reload.email_confirmed
        }.from(false).to(true)
      end
    end

    context "with invalid" do
      shared_examples "shared" do
        it "does not change the user's email confirmation status" do
          expect { subject }.to_not change { user.reload.email_confirmed }
        end
      end

      context "hashed email" do
        let(:hashed_email) { 'invalid' }
        include_examples "shared"
      end

      context "token" do
        let(:token) { 'invalid' }
        include_examples "shared"
      end
    end
  end

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
        [:index, :create].each do |action|
          define_method(action) do
            raise Pundit::NotAuthorizedError
          end
        end
      end

      shared_examples "sets a flash" do
        it "sets a flash" do
          expect(flash[:danger]).to_not be_nil
        end
      end

      describe "in #create" do
        before { post :create }

        include_examples "sets a flash"

        it "redirects to the signin page" do
          expect(response).to redirect_to signin_path
        end
      end

      describe "in other actions" do
        before { get :index }

        include_examples "sets a flash"

        it "redirects to the home page" do
          expect(response).to redirect_to root_path
        end
      end
    end
  end
end