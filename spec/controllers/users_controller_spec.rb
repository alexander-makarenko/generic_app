require 'rails_helper'

describe UsersController, type: :controller do
  describe "routing", type: :routing do
    specify { expect(get    '/users').to_not be_routable }
    specify { expect(post   '/users').to route_to('users#create') }
    specify { expect(get    '/users/new').to_not be_routable }
    specify { expect(get    '/signup').to route_to('users#new') }
    specify { expect(get    '/users/42/edit').to_not be_routable }
    specify { expect(get    '/users/42/settings').to route_to('users#edit', id: '42') }
    specify { expect(get    '/users/42').to_not be_routable }
    specify { expect(put    '/users/42').to route_to('users#update', id: '42') }
    specify { expect(patch  '/users/42').to route_to('users#update', id: '42') }
    specify { expect(delete '/users/42').to_not be_routable }
  end

  describe "authorization:" do
    let(:user) { FactoryGirl.create(:user, :activated) }
    let(:create_params) { Hash[ user: { nil: nil } ] }
    let(:edit_params)   { Hash[ id: user.id ] }
    let(:update_params) { create_params.merge(edit_params) }

    context "when user is not signed in" do
      specify "GET to #new is permitted" do
        get :new
        expect(flash[:error]).to_not match(/not authorized/)
      end

      specify "POST to #create is permitted" do
        post :create, create_params        
        expect(flash[:error]).to_not match(/not authorized/)
      end

      specify "GET to #edit is forbidden" do
        get :edit, edit_params
        expect(flash[:error]).to match(/not authorized/)
      end

      specify "PATCH to #update is forbidden" do
        patch :update, update_params
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

      context "as another user" do
        let(:another_user) { FactoryGirl.create(:user, :activated) }
        before { sign_in_as(another_user, no_capybara: true) }

        specify "GET to #edit is forbidden" do
          get :edit, edit_params
          expect(flash[:error]).to match(/not authorized/)
        end

        specify "PATCH to #update is forbidden" do
          patch :update, update_params
          expect(flash[:error]).to match(/not authorized/)
        end
      end

      context "as target user" do
        specify "GET to #edit is permitted" do
          get :edit, edit_params
          expect(flash[:error]).to_not match(/not authorized/)
        end

        specify "PATCH to #update is permitted" do
          patch :update, update_params
          expect(flash[:error]).to_not match(/not authorized/)
        end
      end
    end
  end
end