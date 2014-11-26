require 'rails_helper'

feature "Update profile" do
  let(:user) { FactoryGirl.create(:user) }
  background { visit settings_path(user) }
  
  scenario "page" do
    expect(page).to have_selector('h1', text: 'Settings')
  end

  scenario "with invalid data" do
    update_profile_of(user, with: {
      name: '',
      email: 'invalid' })

    expect(page).to have_selector('h1', text: 'Settings')
    expect(page).to have_content('error')
  end

  scenario "with valid data, providing wrong password" do
    update_profile_of(user, with: {
      name:     'New name',
      email:    'new_email@example.com',
      password: 'notright' })

    expect(page).to have_selector('h1', text: 'Settings')
    expect(page).to have_selector('div.flash-error', text: 'Wrong password')
  end

  scenario "with valid data and correct password" do
    update_profile_of(user, with: {
      name:     'New name',
      email:    'new_email@example.com',
      password: user.password })
    
    expect(current_path).to eq(root_path)
    expect(page).to have_selector('div.flash-success', text: 'successfully updated')
  end
end