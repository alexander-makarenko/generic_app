require 'rails_helper'

feature "Profile" do
  given(:user) { FactoryGirl.create(:user) }
  background { visit settings_path(user) }
  
  specify "update page" do
    expect(page).to have_selector('h1', text: 'Settings')
  end

  feature "update" do
    given(:new_name)  { 'New Name'}
    given(:new_email) { 'new_email@example.com' }
    given(:current_password) { user.password }
    background do
      update_profile_of(user,
        name: new_name,
        email: new_email,
        password: current_password)
    end

    context "with invalid data" do
      given(:new_name)  { '' }
      given(:new_email) { 'invalid' }

      it "re-renders current page" do
        expect(page).to have_selector('h1', text: 'Settings')
      end

      it "displays validation errors" do
        expect(page).to have_content('error')
      end
    end

    context "with valid data" do
      context "but incorrect password" do
        given(:current_password) { 'notright' }

        it "re-renders current page" do
          expect(page).to have_selector('h1', text: 'Settings')
        end

        it "displays flash message" do
          expect(page).to have_flash(:error, 'Wrong password')
        end
      end

      context "and correct password" do      
        it "redirects to home page" do
          expect(current_path).to eq(root_path)
        end

        it "displays flash message" do
          expect(page).to have_flash(:success, 'successfully updated')
        end
      end
    end
  end
end