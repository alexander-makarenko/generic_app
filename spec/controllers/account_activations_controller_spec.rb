require 'rails_helper'

describe AccountActivationsController, :type => :controller do
  let(:user) { FactoryGirl.create(:user, activation_email_sent_at: 3.hours.ago) }
  let(:encoded_email) { Base64.urlsafe_encode64(user.email) }
  let(:activation_token) { user.activation_token }
  let(:params) { Hash[ token: activation_token, e: encoded_email ] }

  describe "routing", type: :routing do
    specify { expect(get  'user/activate/abc123').to route_to(
      'account_activations#edit', token: 'abc123') }
    
    specify { expect(get  'user/activate').to route_to(
      'account_activations#new') }
    
    specify { expect(post 'user/activate').to route_to(
      'account_activations#create') }
  end

  describe "#edit" do
    before(hook: true) { get :edit, params }
    
    context "when token is invalid", hook: true do
      let(:activation_token) { 'invalid' }

      it "does not activate user" do
        expect(user.reload).to_not be_activated
      end

      it "does not set activation time" do
        expect(user.reload.activated_at).to be_nil
      end

      it "does not clear user's activation_email_sent_at attribute" do
        expect(user.reload.activation_email_sent_at).to_not be_nil
      end
    end

    context "when encoded email is invalid" do
      let(:encoded_email) { 'invalid' }

      it "raises BadRequest exception" do
        expect { get :edit, params }.to raise_error(ActionController::BadRequest)
      end
    end

    context "when link has expired", hook: true do
      let(:user) { FactoryGirl.create(:user, activation_email_sent_at: 1.week.ago) }

      it "does not activate user" do
        expect(user.reload).to_not be_activated
      end

      it "does not set activation time" do
        expect(user.reload.activated_at).to be_nil
      end

      it "does not clear user's activation_email_sent_at attribute" do
        expect(user.reload.activation_email_sent_at).to_not be_nil
      end
    end

    context "when link is valid", hook: true do
      it "activates the user" do
        expect(user.reload).to be_activated
      end

      it "sets activation time" do
        expect(user.reload.activated_at).to_not be_nil
      end

      it "clears user's activation_email_sent_at attribute" do
        expect(user.reload.activation_email_sent_at).to be_nil
      end
    end
  end

  describe "authorization:" do
    let(:user) { FactoryGirl.create(:user, :activated) }
    let(:create_params) { Hash[ email: '' ] }
    let(:edit_params)   { Hash[ token: '' ] }

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
    end
  end
end