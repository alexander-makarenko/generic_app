require 'rails_helper'

feature "Signup" do
  let(:user) { FactoryGirl.build(:user) }
  background { visit signup_path }

  scenario "visit the page" do
    expect(page).to have_selector('h1', text: 'Sign up')
  end

  scenario "submit invalid data" do
    expect { fail_to_sign_up }.to_not change(User, :count)
    expect(page).to have_selector('h1', text: 'Sign up')
    expect(page).to have_content('error')
  end

  scenario "submit valid data" do
    expect { sign_up_as(user) }.to change(User, :count).by(1)
    expect(current_path).to eq(root_path)
    expect(page).to have_selector('div.flash-success', text: 'successfully created')
    expect(page).to have_link('Sign out')
  end
end