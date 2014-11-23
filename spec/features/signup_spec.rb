require 'rails_helper'

feature "Signup" do
  given(:user) { FactoryGirl.build(:user) }
  background do
    clear_deliveries
    visit signup_path
  end

  scenario "page" do
    expect(page).to have_selector('h1', text: 'Sign up')
  end

  scenario "with invalid data" do
    expect { fail_to_sign_up }.to_not change(User, :count)
    expect(page).to have_selector('h1', text: 'Sign up')
    expect(page).to have_content('error')
  end

  scenario "with valid data" do
    expect { sign_up_as(user) }.to change { [User.count, deliveries.count] }.from([0,0]).to([1,1])
    expect(current_path).to eq(root_path)
    expect(page).to have_selector('div.flash-notice', text: 'activation email has been sent')
  end
end

feature "Account activation" do
  given(:user) { FactoryGirl.build(:user) }
  background do
    clear_deliveries
    visit signup_path
    sign_up_as(user)
  end
  
  scenario "visit activation link with incorrect token" do
    visit activation_link_with_incorrect_token

    expect(page).to have_selector('div.flash-error', text: 'Activation link is invalid')
    within('div.flash-error') { expect(page).to have_link('here', href: new_account_activation_path) }
    expect(current_path).to eq(root_path)
  end

  scenario "visit activation link that's expired" do
    User.find_by(email: user.email).update_attribute(:activation_email_sent_at, 3.days.ago)
    visit activation_link
  
    expect(page).to have_selector('div.flash-error', text: 'link has expired')
    within('div.flash-error') { expect(page).to have_link('here', href: new_account_activation_path) }
    expect(current_path).to eq(root_path)
  end

  scenario "visit correct activation link" do
    visit activation_link

    expect(page).to have_selector('div.flash-success', text: 'Thank you for confirming')
    expect(current_path).to eq(signin_path)
  end

  feature "re-request email" do
    before do
      visit activation_link_with_incorrect_token
      within('div.flash-error', text: 'To request another activation email') { click_link('here') }
    end
  
    scenario "page" do
      expect(page).to have_selector('h1', text: 'Request activation email')
      expect(page).to have_content('your email address and password')
    end

    scenario "providing invalid data" do
      expect { click_button 'Submit' }.to_not change(deliveries, :count)
      expect(page).to have_selector('h1', text: 'Request activation email')
      expect(page).to have_selector('div.flash-error', text: 'Invalid')
    end

    scenario "providing valid data" do
      fill_in 'Email',    with: user.email
      fill_in 'Password', with: user.password

      expect { click_button 'Submit' }.to change(deliveries, :count).by(1)
      expect(current_path).to eq(root_path)
      expect(page).to have_selector('div.flash-notice', text: 'activation email has been sent')
    end
  end
end