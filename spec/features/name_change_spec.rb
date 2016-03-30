require 'rails_helper'

feature "Name change page" do
  given(:user) { FactoryGirl.create(:user, :email_confirmed) }
  given(:settings_link) { t 'v.layouts._header.nav_links.settings' }
  given(:name_change_link) { t 'v.users.show.name_change' }
  given(:form_heading) { t 'v.name_changes.new.heading' }
  given!(:original_name) { user.name }
  given(:new_name) { "#{new_first_name} #{new_last_name}" }
  given(:success_box) { '.main .alert-success' }
  
  background do
    visit signin_path
    sign_in_as user
    page.find('#accountDropdown').click
    click_link settings_link
    click_link name_change_link
  end

  subject do
    change_name(new_first_name: new_first_name, new_last_name: new_last_name)
  end

  specify "has a proper heading" do
    expect(page).to have_selector 'h2', text: form_heading
  end

  context "on submission of invalid data" do
    given(:new_first_name) { 'Foo' }
    given(:new_last_name) { '' }
    
    background { subject }

    it "does not change the user's name" do
      click_link settings_link
      within '.main' do
        expect(page).to have_content original_name
        expect(page).to_not have_content new_name
      end
    end

    it "re-renders the page" do
      expect(page).to have_selector 'h2', text: form_heading
    end

    it "shows validation errors" do
      expect(page).to have_selector '.validation-errors'
    end
  end

  context "on submission of valid data" do
    given(:new_first_name) { 'Foo' }
    given(:new_last_name) { 'Bar' }
    given(:name_changed) { t 'c.name_changes.name_changed' }
    
    background { subject }

    it "updates the user's name" do
      within '.main' do
        expect(page).to have_content new_name
        expect(page).to_not have_content original_name
      end
    end

    it "redirects to the profile page of the current user" do
      expect(current_path).to eq account_path
    end

    it "shows an appropriate flash" do
      expect(page).to have_selector(success_box, text: name_changed)
    end
  end

  context "when cancelled" do
    given(:cancel_link) { t 'v.name_changes.new.cancel' }
    
    background { click_link cancel_link }

    it "does not change the user's name" do
      within('.main') { expect(page).to have_content original_name }
    end

    it "shows the profile page of the current user" do
      expect(current_path).to eq account_path
    end
  end
end