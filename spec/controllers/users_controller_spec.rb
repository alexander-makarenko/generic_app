require 'rails_helper'

describe UsersController do
  
  describe "authorization" do
    let(:not_authorized_error) { I18n.t('c.application.flash.error') }
    let(:user) { FactoryGirl.create(:user, :activated) }
    let(:create_params) { Hash[ user: { nil: nil } ] }
    let(:edit_params)   { Hash[ id: user.id ] }
    let(:update_params) { create_params.merge(edit_params) }

    context "when user is not signed in" do
      specify "permits GET to #new" do
        get :new
        expect(flash[:error]).to_not match(not_authorized_error)
      end

      specify "permits POST to #create" do
        post :create, create_params        
        expect(flash[:error]).to_not match(not_authorized_error)
      end

      specify "forbids GET to #edit" do
        get :edit, edit_params
        expect(flash[:error]).to match(not_authorized_error)
      end

      specify "forbids PATCH to #update" do
        patch :update, update_params
        expect(flash[:error]).to match(not_authorized_error)
      end
    end
    
    context "when user is signed in" do
      before { sign_in_as(user, no_capybara: true) }

      specify "forbids GET to #new" do
        get :new
        expect(flash[:error]).to match(not_authorized_error)
      end

      specify "forbids POST to #create" do
        post :create, create_params
        expect(flash[:error]).to match(not_authorized_error)
      end

      context "as another user" do
        let(:another_user) { FactoryGirl.create(:user, :activated) }
        before { sign_in_as(another_user, no_capybara: true) }

        specify "forbids GET to #edit" do
          get :edit, edit_params
          expect(flash[:error]).to match(not_authorized_error)
        end

        specify "forbids PATCH to #update" do
          patch :update, update_params
          expect(flash[:error]).to match(not_authorized_error)
        end
      end

      context "as target user" do
        specify "permits GET to #edit" do
          get :edit, edit_params
          expect(flash[:error]).to_not match(not_authorized_error)
        end

        specify "permits PATCH to #update" do
          patch :update, update_params
          expect(flash[:error]).to_not match(not_authorized_error)
        end
      end
    end
  end
end