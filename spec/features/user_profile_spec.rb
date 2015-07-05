require 'rails_helper'

feature "Profile page" do
  given(:user) { FactoryGirl.create(:user) }
  given(:links) { Hash[
    account_settings: t('v.layouts._header.nav_links.settings'),
    send_confirmation_email: t('c.users.show.link'),
    name_change: t('v.users.show.name_change'),
    email_change: t('v.users.show.email_change'),
    password_change: t('v.users.show.password_change'),
    password_reset: t('v.users.show.password_reset')
  ] }

  background do
    visit signin_path
    sign_in_as(user)
    click_link links[:account_settings]
  end
  
  it "has proper heading" do
    expect(page).to have_selector 'h2', text: t('v.users.show.heading')
  end

  context "when email is not confirmed" do
    shared_examples "shows appropriate flash" do
      it "shows appropriate flash" do
        expect(page).to have_flash :warning, message
      end
    end

    context "and confirmation link hasn't been requested" do
      given(:message) { t('c.users.show.email_not_confirmed',
        link: links[:send_confirmation_email]) }

      include_examples "shows appropriate flash"
    end

    context "immediately after confirmation link was requested" do
      given(:message) { t('c.users.show.confirmation_just_sent') }
      background { click_link links[:send_confirmation_email] }

      include_examples "shows appropriate flash"
    end

    context "3 minutes after confirmation link was requested" do      
      given(:message) { t('c.users.show.confirmation_sent_mins_ago',
        time_ago: time_ago_in_words(user.reload.email_confirmation_sent_at),
        link: links[:send_confirmation_email]) }
      
      background do
        click_link links[:send_confirmation_email]
        Timecop.travel(4.minutes)
        visit current_path # reload page
      end

      include_examples "shows appropriate flash"
    end
  end

  context "when email is confirmed" do
    given(:user) { FactoryGirl.create(:user, :email_confirmed) }

    it "shows no flash" do
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
    expect(page).to have_link links[:name_change], href: new_name_change_path(locale: I18n.locale)
  end

  it "contains email change link" do
    expect(page).to have_link links[:email_change], href: '#'
  end

  it "contains password change link" do
    expect(page).to have_link links[:password_change], href: new_password_change_path(locale: I18n.locale)
  end

  it "contains password reset link" do
    expect(page).to have_link links[:password_reset], href: new_password_reset_path(locale: I18n.locale)
  end
end