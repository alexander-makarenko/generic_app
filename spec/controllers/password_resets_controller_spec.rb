require 'rails_helper'

describe PasswordResetsController, :type => :controller do
  let(:user) { FactoryGirl.create(:user) }
  let(:encoded_email) { Base64.urlsafe_encode64(user.email) }
  let(:password_reset_token) { user.password_reset_token }

  describe "routing", type: :routing do
    specify { expect(get '/reset-password').to route_to('password_resets#new') }
    specify { expect(post '/reset-password').to route_to('password_resets#create') }
    specify { expect(get '/change-password/abc123').to route_to('password_resets#edit', token: 'abc123') }
    specify { expect(patch '/reset-password').to route_to('password_resets#update') }
  end

  describe "#edit" do
    context "when encoded email is invalid" do
      let(:params) { Hash[ token: password_reset_token, e: 'invalid' ] }

      it "raises BadRequest exception" do
        expect { get :edit, params }.to raise_error(ActionController::BadRequest)
      end
    end
  end

  describe "#update" do

    ###################################################################
    #  refactor the tests below
    #  group token and email examples under separate description blocks
    ###################################################################
    #  another idea: define params in the beginning, and then
    #  override its parameters as needed in each example
    ###################################################################

    context "when token is missing" do
      let(:params) { Hash[ e: encoded_email ] }
      before { patch :update, params }

      it "redirects to home page" do
        expect(response).to redirect_to(root_path)
      end
    end

    context "when token is invalid" do
      let(:params) { Hash[ token: 'invalid', e: encoded_email ] }
      before { patch :update, params }

      it "redirects to home page" do
        expect(response).to redirect_to(root_path)
      end
    end

    context "when encoded email is missing" do
      let(:params) { Hash[ token: password_reset_token ] }
      before { patch :update, params }

      it "redirects to home page" do
        expect(response).to redirect_to(root_path)
      end
    end

    context "when encoded email is invalid" do
      let(:params) { Hash[ token: password_reset_token, e: 'invalid' ] }

      it "raises BadRequest exception" do
        expect { patch :update, params }.to raise_error(ActionController::BadRequest)
      end
    end
  end
end
