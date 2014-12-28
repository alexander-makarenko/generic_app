require 'rails_helper'

feature "Profile" do
  given(:user) { FactoryGirl.create(:user, :activated) }
  background do
    visit signin_path
    sign_in_as(user)
    #=======================================================
    # replace with "visit settings_path(user)"
    # after removing the "default_url_options" method from application_controller
    visit settings_path(id: user.id)
    #=======================================================
  end
  
  describe "update" do
    include_examples "page has", h1: t('v.users.edit.header')
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

      include_examples "page has", h1: t('v.users.edit.header')

      it "displays validation errors" do
        expect(page).to have_content('error')
      end
    end

    context "with valid data" do
      context "but incorrect password" do
        given(:current_password) { 'notright' }

        include_examples "page has", h1: t('v.users.edit.header')
        include_examples "shows flash", :error, t('c.users.update.flash.error')
      end

      context "and correct password" do      
        it "redirects to home page" do
          expect(current_path).to eq(root_path)
        end

        include_examples "shows flash", :success,
          t('c.users.update.flash.success')
      end
    end
  end
end