require 'rails_helper'

feature "Signin" do
  given(:user) { FactoryGirl.create(:user) }
  background { visit signin_path }
  
  scenario "page" do
    expect(page).to have_selector('h1', text: 'Sign in')
  end

  scenario "with invalid data" do
    fail_to_sign_in

    expect(page).to have_selector('h1', text: 'Sign in')
    expect(page).to have_link('Sign in')
    expect(page).to_not have_link('Sign out')
    expect(page).to have_selector('div.flash-error', text: 'Invalid')
  end

  feature "with valid data" do
    
    scenario "when account is activated" do
      sign_in_as(user)

      expect(page).to_not have_link('Sign in')
      expect(page).to have_link('Sign out')
      expect(page).to have_selector('div.flash-success', text: 'have signed in')
    end

    scenario "when account is not activated" do
      sign_in_as(user, activated: false)

      expect(page).to have_link('Sign in')
      expect(page).to_not have_link('Sign out')
      expect(page).to have_selector('div.flash-alert', text: 'not activated')
    end
  end

  feature "with keep me signed in" do

    scenario "checked" do
      sign_in_as(user, keep_signed_in: true)
      expire_session_cookies
      visit root_path
      
      expect(page).to_not have_link('Sign in')
      expect(page).to have_link('Sign out')
    end

    scenario "not checked" do
      sign_in_as(user)
      expire_session_cookies
      visit root_path
      
      expect(page).to have_link('Sign in')
      expect(page).to_not have_link('Sign out')
    end
  end

  scenario "with signout" do
    sign_in_as(user)
    click_link('Sign out')
    expect(page).to have_link('Sign in')
    expect(current_path).to eq(root_path)
  end
end