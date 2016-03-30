require 'rails_helper'

feature "Password change page" do
  given(:user) { FactoryGirl.create(:user, :email_confirmed) }
  given(:settings_link) { t 'v.layouts._header.nav_links.settings' }
  given(:password_change_link) { t 'v.users.show.password_change' }
  given(:form_heading) { t 'v.password_changes.new.heading' }
  given(:success_box) { '.main .alert-success' }
  
  background do
    visit signin_path
    sign_in_as user
    page.find('#accountDropdown').click
    click_link settings_link
    click_link password_change_link
  end

  subject do
    change_password(new_password: new_password, current_password: user.password)
  end

  specify "has a proper heading" do
    expect(page).to have_selector 'h2', text: form_heading
  end

  context "on submission of invalid data" do
    given(:new_password) { '' }

    background { subject }

    it "re-renders the page" do
      expect(page).to have_selector 'h2', text: form_heading
    end

    it "shows validation errors" do
      expect(page).to have_selector '.validation-errors'
    end
  end

  context "on submission of valid data" do
    given(:new_password) { 'qwerty' }
    given(:password_changed) { t 'c.password_changes.password_changed' }

    background { subject }

    it "redirects to the profile page of the current user" do
      expect(current_path).to eq account_path
    end

    it "shows an appropriate flash" do
      expect(page).to have_selector(success_box, text: password_changed)
    end
  end

  context "when cancelled" do
    given(:cancel_link) { t 'v.password_changes.new.cancel' }
    
    background { click_link cancel_link }

    it "redirects to the profile page of the current user" do
      expect(current_path).to eq account_path
    end
  end
end