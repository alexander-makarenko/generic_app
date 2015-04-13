require 'rails_helper'

describe PasswordChangesController do
  describe "authorization" do
    let(:user) { FactoryGirl.create(:user, :activated) }    
    let(:not_authorized_error) { t('p.default') }
    let(:create_params) { Hash[ password: '' ] }

    context "when user is not signed in" do
      specify "forbids GET to #new" do
        get :new
        expect(flash[:danger]).to match(not_authorized_error)
      end

      specify "forbids POST to #create" do
        post :create, create_params
        expect(flash[:danger]).to match(not_authorized_error)
      end
    end

    context "when user is signed in" do
      before { sign_in_as(user, no_capybara: true) }

      specify "permits GET to #new" do
        get :new
        expect(flash[:danger]).to_not match(not_authorized_error)
      end

      specify "permits POST to #create" do
        post :create, create_params
        expect(flash[:danger]).to_not match(not_authorized_error)
      end
    end
  end
end