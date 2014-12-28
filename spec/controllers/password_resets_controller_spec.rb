require 'rails_helper'

describe PasswordResetsController do
  let(:user) { FactoryGirl.create(:user) }
  let(:password_reset_token) { user.password_reset_token }
  let(:encoded_email) { Base64.urlsafe_encode64(user.email) }
  let(:params) { Hash[ token: password_reset_token, e: encoded_email ] }

  describe "#edit" do
    context "when encoded email is invalid" do
      let(:encoded_email) { 'invalid' }

      it "raises BadRequest exception" do
        expect { get :edit, params }.to raise_error(ActionController::BadRequest)
      end
    end
  end

  describe "#update" do
    before(hook: true) { patch :update, params }

    context "when token is missing", hook: true do
      let(:password_reset_token) { nil }

      it "redirects to home page" do
        expect(response).to redirect_to(root_path)
      end
    end

    context "when token is invalid", hook: true do
      let(:password_reset_token) { 'invalid' }

      it "redirects to home page" do
        expect(response).to redirect_to(root_path)
      end
    end

    context "when encoded email is missing", hook: true do
      let(:encoded_email) { nil }

      it "redirects to home page" do
        expect(response).to redirect_to(root_path)
      end
    end

    context "when encoded email is invalid" do
      let(:encoded_email) { 'invalid' }

      it "raises BadRequest exception" do
        expect { patch :update, params }.to raise_error(ActionController::BadRequest)
      end
    end
  end

  describe "authorization" do
    let(:not_authorized_error) { I18n.t('c.application.flash.error') }
    let(:user) { FactoryGirl.create(:user, :activated) }
    let(:create_params) { Hash[ email: '' ] }
    let(:edit_params)   { Hash[ token: '' ] }
    let(:update_params) { Hash[] }

    context "when user is not signed in" do
      specify "permits GET to #new" do
        get :new
        expect(flash[:error]).to_not match(not_authorized_error)
      end

      specify "permits POST to #create" do
        post :create, create_params
        expect(flash[:error]).to_not match(not_authorized_error)
      end

      specify "permits GET to #edit" do
        get :edit, edit_params
        expect(flash[:error]).to_not match(not_authorized_error)
      end

      specify "permits PATCH to #update" do
        patch :update, update_params
        expect(flash[:error]).to_not match(not_authorized_error)
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

      specify "forbids GET to #edit" do
        get :edit, edit_params
        expect(flash[:error]).to match(not_authorized_error)
      end

      specify "forbids PATCH to #update" do
        patch :update, update_params
        expect(flash[:error]).to match(not_authorized_error)
      end
    end
  end
end