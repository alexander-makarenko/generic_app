require 'rails_helper'

feature "Signup" do
  given(:user)         { FactoryGirl.build(:user) }
  given(:invalid_user) { FactoryGirl.build(:user, :invalid) }
  background do
    deliveries.clear
    visit signup_path
  end

  scenario "page" do
    expect(page).to have_selector('h1', text: 'Sign up')
  end

  scenario "with invalid data" do
    expect { sign_up_as(invalid_user) }.to_not change(User, :count)
    expect(page).to have_selector('h1', text: 'Sign up')
    expect(page).to have_content('error')
  end

  scenario "with valid data" do
    expect { sign_up_as(user) }.to change { [User.count, deliveries.count] }.from([0,0]).to([1,1])
    expect(current_path).to eq(root_path)
    expect(page).to have_selector('div.flash-notice', text: 'activation email has been sent')
  end
end

feature "Account activation link" do
  given(:user) { FactoryGirl.build(:user) }
  given(:nonexistent_user) { FactoryGirl.build(:user) }
  background do
    deliveries.clear
    visit signup_path
    sign_up_as(user)
  end
  
  scenario "when token is invalid" do
    visit activation_link(with: :invalid_token)

    expect(page).to have_selector('div.flash-error', text: 'link is invalid')
    expect(current_path).to eq(root_path)
  end

  scenario "when encoded email is invalid" do
    # add a test here after implementing BadRequest handling
    # (the user will probably be redirected somewhere)

    # visit activation_link(with: :invalid_encoded_email)
  end

  scenario "when encoded email is missing" do
    visit activation_link(with: :no_encoded_email)
    
    expect(page).to have_selector('div.flash-error', text: 'link is invalid')
    expect(current_path).to eq(root_path)
  end

  scenario "when link has expired" do
    User.find_by(email: user.email).update_attribute(:activation_email_sent_at, 3.days.ago)
    visit activation_link
  
    expect(page).to have_selector('div.flash-error', text: 'link has expired')
    expect(current_path).to eq(root_path)
  end

  scenario "when link is valid" do
    visit activation_link

    expect(page).to have_selector('div.flash-success', text: 'Thank you for confirming')
    expect(current_path).to eq(signin_path)
  end

  feature "re-request" do
    before do
      visit activation_link(with: :invalid_token)
      within('div.flash-error', text: 'To request another activation email') { click_link('here') }
    end
  
    scenario "page" do
      expect(page).to have_selector('h1', text: 'Request activation email')
    end

    scenario "providing invalid data" do
      expect { rerequest_activation_email_as(nonexistent_user) }.to_not change(deliveries, :count)
      expect(page).to have_selector('h1', text: 'Request activation email')
      expect(page).to have_selector('div.flash-error', text: 'Invalid')
    end

    scenario "providing valid data" do
      expect { rerequest_activation_email_as(user) }.to change(deliveries, :count).by(1)
      expect(current_path).to eq(root_path)
      expect(page).to have_selector('div.flash-notice', text: 'activation email has been sent')
    end
  end
end