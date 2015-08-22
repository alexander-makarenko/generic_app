require 'rails_helper'

feature "Friendly redirection" do
  given(:user) { FactoryGirl.create(:user) }

  context "when a user, asked to sign in to view a page, signs in" do
    background do
      visit new_password_change_path      
      sign_in_as user
    end
  
    it "redirects the user back to the page they tried to view" do
      expect(current_path).to eq new_password_change_path
    end

    context "and then out and in again" do
      background do
        click_link t('v.layouts._header.nav_links.sign_out')
        visit signin_path
        sign_in_as user
      end

      it "does not redirect the user to the page they tried to view before first sign in" do
        expect(current_path).to eq root_path
      end
    end
  end
end