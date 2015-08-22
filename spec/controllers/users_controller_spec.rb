require 'rails_helper'

describe UsersController do
  describe "authorization" do
    let(:user) { FactoryGirl.create(:user, :email_confirmed) }
    let(:create_params)   { Hash[ user: { nil: nil } ] }
    let(:show_params)     { Hash[] }
    let(:validate_params) { Hash[ user: { nil: nil } ] }

    context "when the user is not signed in" do
      before { bypass_rescue }

      it "permits GET to #new" do
        expect { get :new }.to be_permitted
      end

      it "permits POST to #create" do
        expect { post :create, create_params }.to be_permitted
      end

      it "forbids GET to #show" do
        expect { get :show, show_params }.to_not be_permitted
      end

      it "permits POST to #validate" do
        expect { xhr :post, :validate, validate_params }.to be_permitted
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

      it "permits GET to #show" do
        expect { get :show, show_params }.to be_permitted
      end

      it "forbids POST to #validate" do
        expect { xhr :post, :validate, validate_params }.to_not be_permitted
      end

      # context "as another user" do
      #   let(:another_user) { FactoryGirl.create(:user, :email_confirmed) }
      #   before do
      #     bypass_rescue
      #     sign_in_as(another_user, no_capybara: true)
      #   end

      #   it "forbids GET to #show" do
      #     expect { get :show, show_params }.to_not be_permitted
      #   end
      # end

      # context "as target user" do
      #   it "permits GET to #show" do
      #     expect { get :show, show_params }.to be_permitted
      #   end
      # end
    end

    describe "exception handler" do
      controller(UsersController) do
        [:index, :show].each do |action|
          define_method(action) do
            raise Pundit::NotAuthorizedError
          end
        end
      end

      describe "in #show" do
        before { get :show, id: 'foo' }

        it "sets a flash" do
          expect(flash[:danger]).to_not be_nil
        end

        it "redirects to the signin page" do
          expect(response).to redirect_to signin_path
        end
      end

      describe "in other actions" do
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
end