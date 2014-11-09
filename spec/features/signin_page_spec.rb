require 'rails_helper'

feature "Signin" do
  let(:user) { FactoryGirl.create(:user) }
  background { visit signin_path }
  
  scenario "visit the page" do
    expect(page).to have_selector('h1', text: 'Sign in')
  end

  scenario "submit invalid data" do
    fail_to_sign_in

    expect(page).to have_selector('h1', text: 'Sign in')
    expect(page).to have_link('Sign in')
    expect(page).to_not have_link('Sign out')
    expect(page).to have_selector('div.flash-error', text: 'Invalid')
  end

  scenario "submit valid data" do
    sign_in_as(user)
    
    expect(page).to_not have_link('Sign in')
    expect(page).to have_link('Sign out')
    expect(page).to have_selector('div.flash-success', text: 'have been signed in')
  end

  feature "keep me signed in" do
    subject { page }

    context "when checked" do
      background do
        sign_in_as(user, keep_signed_in: true)
        expire_session_cookies
        visit root_path
      end
      
      it { is_expected.to_not have_link('Sign in') }
      it { is_expected.to have_link('Sign out') }
    end

    context "when not checked" do
      background do
        sign_in_as(user)
        expire_session_cookies
        visit root_path
      end

      it { is_expected.to have_link('Sign in') }
      it { is_expected.to_not have_link('Sign out') }
    end
  end

  scenario "sign out" do
    sign_in_as(user)
    click_link('Sign out')
    expect(page).to have_link('Sign in')
    expect(current_path).to eq(root_path)
  end
end