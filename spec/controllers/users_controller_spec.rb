require 'rails_helper'

describe UsersController do
  describe "authorization" do
    let(:user) { FactoryGirl.create(:user, :email_confirmed) }
    let(:create_params)   { Hash[ user: { nil: nil } ] }    
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
        expect { get :show }.to_not be_permitted
      end

      it "forbids GET to #index" do
        expect { get :index }.to_not be_permitted
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
        expect { get :show }.to be_permitted
      end

      context "as a regular user" do
        it "forbids GET to #index" do
          expect { get :index }.to_not be_permitted
        end
      end

      context "as an admin user" do
        let(:user) { FactoryGirl.create(:user, :admin) }

        it "permits GET to #index" do
          expect { get :index }.to be_permitted
        end
      end

      it "forbids POST to #validate" do
        expect { xhr :post, :validate, validate_params }.to_not be_permitted
      end
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

  describe "#index" do
    let!(:first_user)  { FactoryGirl.create(:user, :admin) }
    let!(:second_user) { FactoryGirl.create(:user) }

    before do
      sign_in_as(first_user, no_capybara: true)
      get :index
    end

    it "sorts @users by id in ascending order" do
      expect(second_user.id).to be > first_user.id
      expect(assigns(:users)).to eq([first_user, second_user])
    end
  end
end