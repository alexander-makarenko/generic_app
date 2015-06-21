require 'rails_helper'

feature "Profile page" do
  given(:user) { FactoryGirl.create(:user) }
  background do
    visit signin_path
    sign_in_as(user)    
    click_link t('v.layouts._header.nav_links.settings')
  end
  
  it "has proper heading" do
    expect(page).to have_selector 'h2', text: t('v.users.show.heading')
  end

  context "when email is not confirmed" do
    it "shows warning flash" do
      expect(page).to have_flash :warning, t('c.users.show.flash.warning.1',
        link: t('c.users.show.flash.link'))
    end
  end

  context "when email is confirmed" do
    given(:user) { FactoryGirl.create(:user, :email_confirmed) }

    it "does not show warning flash" do
      expect(page).to_not have_flash :warning
    end
  end  

  it "contains user's full name and email" do
    within('.main') do
      expect(page).to have_content user.name
      expect(page).to have_content user.email
    end
  end

  it "contains name change link" do
    expect(page).to have_link t('v.users.show.name_change'),
      href: new_name_change_path(locale: I18n.locale)
  end

  it "contains email change link" do
    expect(page).to have_link t('v.users.show.email_change'), href: '#'
  end

  it "contains password change link" do
    expect(page).to have_link t('v.users.show.password_change'),
      href: new_password_change_path(locale: I18n.locale)
  end

  it "contains password reset link" do
    expect(page).to have_link t('v.users.show.password_reset'),
      href: new_password_reset_path(locale: I18n.locale)
  end
end