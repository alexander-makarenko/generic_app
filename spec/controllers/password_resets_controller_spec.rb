require 'rails_helper'

describe PasswordResetsController do

  describe "authorization" do
    let(:not_authorized_error) { t('p.default') }
    let(:create_params) { Hash[ password_reset: Hash[ email: '' ]] }
    let(:edit_params)   { Hash[ hashed_email: 'email', token: 'token' ] }
    let(:update_params) { Hash[ password_reset: Hash[ password: '']] }
    
    specify "permits GET to #new" do
      get :new
      expect(flash[:danger]).to_not match(not_authorized_error)
    end

    specify "permits POST to #create" do
      post :create, create_params
      expect(flash[:danger]).to_not match(not_authorized_error)
    end

    specify "permits GET to #edit" do
      get :edit, edit_params
      expect(flash[:danger]).to_not match(not_authorized_error)
    end

    specify "permits PATCH to #update" do
      patch :update, update_params
      expect(flash[:danger]).to_not match(not_authorized_error)
    end
  end
end