require 'rails_helper'

describe LocaleChangesController do
  describe "authorization" do    
    before { bypass_rescue }
       
    it "permits POST to #create" do
      expect { post :create }.to be_permitted
    end
  end
end