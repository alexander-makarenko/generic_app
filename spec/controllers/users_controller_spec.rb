require 'rails_helper'

describe UsersController do
  describe "authorization" do
    let(:user) { FactoryGirl.create(:user, :email_confirmed) }
    let(:create_params)   { Hash[ user: { nil: nil } ] }
    let(:show_params)     { Hash[] }
    let(:validate_params) { Hash[ user: { nil: nil } ] }
    before { bypass_rescue }

    context "when user is not signed in" do
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

    context "when user is signed in" do
      before { sign_in_as(user, no_capybara: true) }

      it "forbids GET to #new" do
        expect { get :new }.to_not be_permitted
      end

      it "forbids POST to #create" do
        expect { post :create, create_params }.to_not be_permitted
      end

      it "forbids POST to #validate" do
        expect { xhr :post, :validate, validate_params }.to_not be_permitted
      end

      it "permits GET to #show" do
        expect { get :show, show_params }.to be_permitted
      end

      # context "as another user" do
      #   let(:another_user) { FactoryGirl.create(:user, :email_confirmed) }
      #   before { sign_in_as(another_user, no_capybara: true) }

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
  end
end