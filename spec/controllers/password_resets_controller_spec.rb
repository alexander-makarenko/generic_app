require 'rails_helper'

describe PasswordResetsController do
  describe "#update" do
    let(:user) { FactoryGirl.create(:user, :password_reset_sent) }
    let(:params) do
      { user: { password: new_password, password_confirmation: new_password } }
    end

    before do
      session[:hashed_email] = User.digest(user.email)
      session[:token] = user.password_reset_token
    end

    subject { patch :update, params }

    context "with invalid data" do
      let(:new_password) { '' }

      it "does not update the user's password" do
        expect { subject }.to_not change { user.reload.password_digest }
      end

      it "does not clear the user's password_reset_sent_at attribute" do
        expect { subject }.to_not change { user.reload.password_reset_sent_at }
      end
    end

    context "with valid data" do
      let(:new_password) { 'new_password' }

      it "updates the user's password" do
        expect { subject }.to change { user.reload.password_digest }
      end

      it "clears the user's password_reset_sent_at attribute" do
        expect { subject }.to change {
          user.reload.password_reset_sent_at
        }.from(ActiveSupport::TimeWithZone).to(nil)
      end
    end
  end

  describe "authorization" do
    let(:create_params) { { password_reset: { email: '' } } }
    let(:edit_params)   { { hashed_email: 'foo', token: 'bar' } }
    before { bypass_rescue }
    
    it "permits GET to #new" do
      expect { get :new }.to be_permitted
    end

    it "permits POST to #create" do
      expect { post :create, create_params }.to be_permitted
    end

    it "permits GET to #edit" do
      expect { get :edit, edit_params }.to be_permitted
    end

    it "permits PATCH to #update" do
      expect { patch :update }.to be_permitted
    end
  end
end