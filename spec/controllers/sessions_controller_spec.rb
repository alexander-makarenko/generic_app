require 'rails_helper'

describe SessionsController do
  
  describe "authorization" do
    let(:not_authorized_error) { I18n.t('c.application.flash.error') }
    let(:user) { FactoryGirl.create(:user, :activated) }
    let(:create_params) { Hash[ email: '' ] }

    context "when user is not signed in" do
      specify "permits GET to #new" do
        get :new
        expect(flash[:error]).to_not match(not_authorized_error)
      end

      specify "permits POST to #create" do
        post :create, create_params
        expect(flash[:error]).to_not match(not_authorized_error)
      end

      specify "forbids DELETE to #destroy" do
        delete :destroy
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

      specify "permits DELETE to #destroy" do
        delete :destroy
        expect(flash[:error]).to_not match(not_authorized_error)
      end
    end
  end
end