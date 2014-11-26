require 'rails_helper'

describe AccountActivationsController, :type => :controller do
  let(:user) { FactoryGirl.create(:user, activation_email_sent_at: 3.hours.ago) }
  let(:encoded_email) { Base64.urlsafe_encode64(user.email) }
  let(:activation_token) { user.activation_token }

  describe "routing", type: :routing do
    specify { expect(get  '/activate/abc123').to route_to('account_activations#edit', token: 'abc123') }
    specify { expect(get  '/resend-activation').to route_to('account_activations#new') }
    specify { expect(post '/resend-activation').to route_to('account_activations#create') }
  end

  describe "#edit" do

    context "when token is invalid" do
      let(:params) { Hash[ token: 'invalid', e: encoded_email ] }
      before { get :edit, params }

      it "does not activate the user" do
        expect(user).to_not be_activated
        expect(user.activated_at).to be_blank
      end
    end

    context "when encoded email is invalid" do
      let(:params) { Hash[ token: activation_token, e: 'invalid' ] }

      it "raises BadRequest exception" do
        expect { get :edit, params }.to raise_error(ActionController::BadRequest)
      end
    end

    context "when encoded email is missing" do
      let(:params) { Hash[ token: activation_token ] }

      it "does not raise exception" do
        expect { get :edit, params }.to_not raise_error
      end
    end

    context "when link has expired" do
      let(:user) { FactoryGirl.create(:user, activation_email_sent_at: 1.week.ago) }
      let(:params) { Hash[ e: encoded_email, token: activation_token ] }
      before { get :edit, params }

      it "does not activate the user" do
        expect(user.reload).to_not be_activated
        expect(user.reload.activated_at).to be_blank
      end
    end

    context "when link is valid" do 
      let(:params) { Hash[ e: encoded_email, token: activation_token ] }
      before { get :edit, params }
      
      it "activates the user" do
        expect(user.reload).to be_activated
        expect(user.reload.activated_at).to_not be_blank
      end
    end
  end
end