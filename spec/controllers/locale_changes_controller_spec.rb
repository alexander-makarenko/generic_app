require 'rails_helper'

describe LocaleChangesController do
  describe "#create" do
    let(:user) { FactoryGirl.create(:user) }
    let(:params) { { commit: 'Русский' } }

    subject { post :create, params }

    describe "when the user is signed in" do
      before { sign_in_as(user, no_capybara: true) }

      it "updates the user's locale preference" do
        expect { subject }.to change { user.reload.locale }.from(:en).to(:ru)
      end
    end
  end

  describe "authorization" do
    before do
      bypass_rescue
      @request.env['HTTP_REFERER'] = 'http://test.com/'
    end
       
    it "permits POST to #create" do
      expect { post :create }.to be_permitted
    end
  end
end