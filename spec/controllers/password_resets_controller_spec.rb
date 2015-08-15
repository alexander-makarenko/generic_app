require 'rails_helper'

describe PasswordResetsController do
  describe "authorization" do
    let(:create_params) { Hash[ password_reset: Hash[ email: '' ]] }
    let(:edit_params)   { Hash[ hashed_email: 'foo', token: 'bar' ] }
    let(:update_params) { Hash[ password_reset: Hash[ password: '']] }
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
      expect { patch :update, update_params }.to be_permitted
    end
  end
end