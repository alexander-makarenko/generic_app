require 'rails_helper'

signin_link = t('v.layouts._header.nav_links.sign_in')
signout_link = t('v.layouts._header.nav_links.sign_out')

shared_examples "user is not signed in" do
  it "has signin link" do
    expect(page).to have_link(signin_link)
  end
  
  it "does not have signout link" do
    expect(page).to_not have_link(signout_link)
  end
end

shared_examples "user is signed in" do
  it "has signout link" do
    expect(page).to have_link(signout_link)
  end

  it "does not have signin link" do
    expect(page).to_not have_link(signin_link)
  end
end

feature "Signin" do
  given(:not_activated_user) { FactoryGirl.create(:user) }
  given(:activated_user)     { FactoryGirl.create(:user, :activated) }
  given(:nonexistent_user)   { FactoryGirl.build(:user) }
  background { visit signin_path }
  
  include_examples "page has", h1: t('v.sessions.new.header')

  context "with invalid data" do
    background { sign_in_as(nonexistent_user) }
    
    include_examples "user is not signed in"    
    include_examples "page has", h1: t('v.sessions.new.header')
    include_examples "shows flash", :error, t('c.sessions.create.flash.error')
  end

  context "with valid data" do
    context "as non-activated user" do
      background { sign_in_as(not_activated_user) }

      include_examples "user is not signed in"
      include_examples "shows flash", :alert, t(
        'c.sessions.create.flash.alert', link: t('c.sessions.create.flash.link'))
    end
    
    context "as activated user" do
      let(:keep_signed_in) { Hash[ keep_signed_in: false ] }
      background { sign_in_as(activated_user, keep_signed_in) }

      include_examples "user is signed in"
      include_examples "shows flash", :success, t(
        'c.sessions.create.flash.success')

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
end

feature "Signout" do
  given(:activated_user) { FactoryGirl.create(:user, :activated) }
  background do
    visit signin_path
    sign_in_as(activated_user)
    click_link t('v.layouts._header.nav_links.sign_out')
  end

  include_examples "user is not signed in"
  include_examples "shows flash", :notice, t('c.sessions.destroy.flash.notice')

  it "redirects to home page" do
    expect(current_path).to eq(root_path)
  end  
end