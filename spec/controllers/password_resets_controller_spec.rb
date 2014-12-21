require 'rails_helper'

describe PasswordResetsController, :type => :controller do
  let(:user) { FactoryGirl.create(:user) }
  let(:password_reset_token) { user.password_reset_token }
  let(:encoded_email) { Base64.urlsafe_encode64(user.email) }
  let(:params) { Hash[ token: password_reset_token, e: encoded_email ] }

  describe "routing", type: :routing do
    specify { expect(get '/user/recover').to route_to(
      'password_resets#new') }

    specify { expect(post '/user/recover').to route_to(
      'password_resets#create') }

    specify { expect(get '/user/recover/abc123').to route_to(
      'password_resets#edit', token: 'abc123') }

    specify { expect(patch '/user/recover').to route_to(
      'password_resets#update') }
  end

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

  describe "authorization:" do
    let(:user) { FactoryGirl.create(:user, :activated) }
    let(:create_params) { Hash[ email: '' ] }
    let(:edit_params)   { Hash[ token: '' ] }
    let(:update_params) { Hash[] }

    context "when user is not signed in" do
      specify "GET to #new is permitted" do
        get :new
        expect(flash[:error]).to_not match(/not authorized/)
      end

      specify "POST to #create is permitted" do
        post :create, create_params
        expect(flash[:error]).to_not match(/not authorized/)
      end

      specify "GET to #edit is permitted" do
        get :edit, edit_params
        expect(flash[:error]).to_not match(/not authorized/)
      end

      specify "PATCH to #update is permitted" do
        patch :update, update_params
        expect(flash[:error]).to_not match(/not authorized/)
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

      specify "GET to #edit is forbidden" do
        get :edit, edit_params
        expect(flash[:error]).to match(/not authorized/)
      end

      specify "PATCH to #update is forbidden" do
        patch :update, update_params
        expect(flash[:error]).to match(/not authorized/)
      end
    end
  end
end