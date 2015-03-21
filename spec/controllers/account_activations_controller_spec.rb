require 'rails_helper'

describe AccountActivationsController do

  describe "authorization" do
    let(:not_signed_in_error) { t('p.account_activation_policy.new?') }
    let(:already_activated_error) { t('c.account_activations.already_activated') }
    let(:create_params) { Hash[ email: '', password: '' ] }
    let(:edit_params)   { Hash[ hashed_email: 'hashed_email', token: 'token' ] }

    context "when user is not signed in" do
      specify "forbids GET to #new" do
        get :new
        expect(flash[:error]).to match(not_signed_in_error)
      end

      specify "forbids POST to #create" do
        post :create, create_params
        expect(flash[:error]).to match(not_signed_in_error)
      end

      specify "permits GET to #edit" do
        get :edit, edit_params
        expect(flash[:error]).to_not match(not_signed_in_error)
      end
    end
    
    context "when user is signed in" do
      before { sign_in_as(user, no_capybara: true) }

      context "and not activated" do
        let(:user) { FactoryGirl.create(:user) }        

        specify "permits GET to #new" do
          get :new
          expect(flash[:error]).to_not match(not_signed_in_error)
        end

        specify "permits POST to #create" do
          post :create, create_params
          expect(flash[:error]).to_not match(not_signed_in_error)
        end

        specify "permits GET to #edit" do
          get :edit, edit_params
          expect(flash[:error]).to_not match(not_signed_in_error)
        end
      end

      context "and already activated" do
        let(:user) { FactoryGirl.create(:user, :activated) }

        specify "forbids GET to #new" do
          get :new
          expect(flash[:error]).to match(already_activated_error)
        end

        specify "forbids POST to #create" do
          post :create, create_params
          expect(flash[:error]).to match(already_activated_error)
        end
      end
    end
  end
end