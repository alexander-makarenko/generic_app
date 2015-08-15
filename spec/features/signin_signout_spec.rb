require 'rails_helper'

feature "Signin" do
  given(:user) { FactoryGirl.create(:user) }
  given(:nonexistent_user) { FactoryGirl.build(:user) }
  background { visit signin_path }
  
  specify "form has proper header" do
    expect(page).to have_selector('form h3', text: t('v.sessions.new.header'))
  end
  
  context "with invalid data" do
    background { sign_in_as(nonexistent_user) }
    
    include_examples "user is not signed in"

    it "displays user's name in header" do
      expect(page).to_not have_selector('header nav li', text: user.name)
    end

    it "re-renders page" do
      expect(page).to have_selector('form h3', text: t('v.sessions.new.header'))
    end

    it "displays flash" do
      expect(page).to have_flash :danger, t('c.sessions.create.invalid')
    end
  end

  context "with valid data" do
    let(:keep_signed_in) { Hash[ keep_signed_in: false ] }
    background { sign_in_as(user, keep_signed_in) }

    include_examples "user is signed in"

    it "displays user's name in header" do
      expect(page).to have_selector('header nav li', text: user.name)
    end

    feature "and keep me signed in" do
      background do
        expire_session_cookies
        visit root_path
      end

      context "not checked, after browser reopening" do
        include_examples "user is not signed in"
      end

      context "checked, after browser reopening" do
        let(:keep_signed_in) { Hash[ keep_signed_in: true ] }
        
        include_examples "user is signed in"
      end
    end
  end
end

feature "Signout" do
  given(:user) { FactoryGirl.create(:user, locale: :ru) }
  background do
    visit signin_path
    sign_in_as(user)
    click_link t('v.layouts._header.nav_links.sign_out')
  end

  include_examples "user is not signed in"

  it "redirects to the home page" do
    expect(current_path).to eq root_path
  end

  it "leaves the locale as the user had it set in their preferences" do
    expect(I18n.locale).to eq :ru
  end
end