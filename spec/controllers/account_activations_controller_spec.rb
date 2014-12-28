require 'rails_helper'

describe AccountActivationsController do
  let(:user) { FactoryGirl.create(:user, activation_email_sent_at: 3.hours.ago) }
  let(:encoded_email) { Base64.urlsafe_encode64(user.email) }
  let(:activation_token) { user.activation_token }
  let(:params) { Hash[ token: activation_token, e: encoded_email ] }

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

  describe "authorization" do
    let(:not_authorized_error) { I18n.t('c.application.flash.error') }
    let(:user) { FactoryGirl.create(:user, :activated) }    
    let(:create_params) { Hash[ email: '' ] }
    let(:edit_params)   { Hash[ token: '' ] }

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
    end
  end
end