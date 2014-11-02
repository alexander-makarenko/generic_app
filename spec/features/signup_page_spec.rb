require 'rails_helper'

feature "Signup" do
  let(:user) { FactoryGirl.build(:user) }
  background { visit signup_path }
  
  scenario "visit the page" do
    expect(page).to have_selector('h1', text: 'Sign up')
  end

  scenario "submit invalid data" do
    expect { click_button 'Create my account' }.to_not change(User, :count)
    expect(page).to have_content('error')
  end

  scenario "submit valid data" do
    expect do
      fill_in 'Name', with: user.name
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      fill_in 'Confirm password', with: user.password_confirmation
      click_button 'Create my account'
    end.to change(User, :count).by(1)
    expect(page).to have_content('successfully created')
  end
end