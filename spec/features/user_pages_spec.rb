require 'rails_helper'

feature "Settings page" do
  let(:user) { FactoryGirl.create(:user) }
  background { visit settings_path(user) }
  
  scenario "visit the page" do
    expect(page).to have_selector('h1', text: 'Settings')
  end

  scenario "submit invalid data" do
    fail_to_update_profile

    expect(page).to have_selector('h1', text: 'Settings')
    expect(page).to have_content('error')
  end

  scenario "submit valid data but wrong password" do
    update_profile_of(user, with: {
      name:     'New name',
      email:    'new_email@example.com',
      password: 'notright'
    })

    expect(page).to have_selector('div.flash-error', text: 'Wrong password')
  end

  scenario "submit valid data and correct password" do
    update_profile_of(user, with: {
      name:     'New name',
      email:    'new_email@example.com',
      password: user.password
    })
    
    expect(current_path).to eq(root_path)
    expect(page).to have_selector('div.flash-success', text: 'successfully updated')
  end
end