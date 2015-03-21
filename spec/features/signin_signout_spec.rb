require 'rails_helper'

feature "Signin" do
  given(:user) { FactoryGirl.create(:user) }
  given(:nonexistent_user) { FactoryGirl.build(:user) }
  background { visit signin_path }
  
  include_examples "page has", "div.header" => t('v.sessions.new.header')
  
  context "with invalid data" do
    background { sign_in_as(nonexistent_user) }
    
    include_examples "user is not signed in"    

    it "displays user's name in header" do
      expect(page).to_not have_selector('header nav li', text: user.name)
    end

    include_examples "page has", "div.header" => t('v.sessions.new.header')

    it "displays flash" do
      expect(page).to have_flash :error, t('c.sessions.create.flash.error')
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
  given(:user) { FactoryGirl.create(:user) }
  background do
    visit signin_path
    sign_in_as(user)
    click_link t('v.layouts._header.nav_links.sign_out')
  end

  include_examples "user is not signed in"  

  it "redirects to home page" do
    expect(current_path).to eq(root_path)
  end  
end