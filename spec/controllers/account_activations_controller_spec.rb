require 'rails_helper'

describe AccountActivationsController, :type => :controller do
  let(:user) { FactoryGirl.create(:user) }

  describe "routing", type: :routing do
    specify { expect(get  '/activate').to route_to('account_activations#edit') }
    specify { expect(get  '/resend-activation').to route_to('account_activations#new') }
    specify { expect(post '/resend-activation').to route_to('account_activations#create') }
  end

  describe "#edit" do

    context "when activation token is incorrect" do
      let(:params) { Hash[email: user.email, token: 'incorrect'] }

      before do
        user.update_attribute(:activation_email_sent_at, 3.hours.ago)
        get :edit, params
      end

      it "should not activate the user" do
        expect(user).to_not be_activated
        expect(user.activated_at).to be_blank
      end
    end

    context "when activation link has expired" do
      let(:params) { Hash[email: user.email, token: user.activation_token] }

      before do
        user.update_attribute(:activation_email_sent_at, 3.days.ago)
        get :edit, params
      end

      it "should not activate the user" do
        expect(user.reload).to_not be_activated
        expect(user.reload.activated_at).to be_blank
      end
    end    

    context "when activation token is correct and link not expired" do 
      let(:params) { Hash[email: user.email, token: user.activation_token] }

      before do
        user.update_attribute(:activation_email_sent_at, 3.hours.ago)
        get :edit, params
      end
      
      it "should activate the user" do
        expect(user.reload).to be_activated
        expect(user.reload.activated_at).to_not be_blank
      end
    end
  end
end