require 'rails_helper'

describe SessionsController, :type => :controller do
  describe "routing", type: :routing do
    specify { expect(get    '/signin').to   route_to('sessions#new') }
    specify { expect(post   '/sessions').to route_to('sessions#create') }
    specify { expect(delete '/signout').to  route_to('sessions#destroy') }
  end

  describe "authorization:" do
    let(:user) { FactoryGirl.create(:user, :activated) }
    let(:create_params) { Hash[ email: '' ] }

    context "when user is not signed in" do
      specify "GET to #new is permitted" do
        get :new
        expect(flash[:error]).to_not match(/not authorized/)
      end

      specify "POST to #create is permitted" do
        post :create, create_params
        expect(flash[:error]).to_not match(/not authorized/)
      end

      specify "DELETE to #destroy is forbidden" do
        delete :destroy
        expect(flash[:error]).to match(/not authorized/)
      end
    end
    
    context "when user is signed in" do
      before { sign_in_as(user, no_capybara: true) }

      specify "GET to #new is forbidden" do
        get :new
        expect(flash[:error]).to match(/not authorized/)
      end

      specify "POST to #create is forbidden" do
        post :create, create_params
        expect(flash[:error]).to match(/not authorized/)
      end

      specify "DELETE to #destroy is permitted" do
        delete :destroy
        expect(flash[:error]).to_not match(/not authorized/)
      end
    end
  end
end