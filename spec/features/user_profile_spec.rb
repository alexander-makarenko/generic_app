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
  
  it "has a proper heading" do
    expect(page).to have_selector 'h2', text: t('v.users.show.heading')
  end

  context "when the email is not confirmed" do
    shared_examples "shows an appropriate flash" do
      it "shows an appropriate flash" do
        expect(page).to have_flash :warning, message
      end
    end

    context "and a confirmation link has not been requested" do
      given(:message) { t('c.users.show.email_not_confirmed',
        link: links[:send_confirmation_email]) }

      include_examples "shows an appropriate flash"
    end

    context "immediately after a confirmation link was requested" do
      given(:message) { t('c.users.show.confirmation_just_sent') }
      background { click_link links[:send_confirmation_email] }

      include_examples "shows an appropriate flash"
    end

    context "3 minutes after a confirmation link was requested" do
      given(:message) { t('c.users.show.confirmation_sent_mins_ago',
        time_ago: time_ago_in_words(user.reload.email_confirmation_sent_at),
        link: links[:send_confirmation_email]) }
      
      background do
        click_link links[:send_confirmation_email]
        Timecop.travel(4.minutes)
        visit current_path # reload page
      end

      include_examples "shows an appropriate flash"
    end
  end

  context "when the email is confirmed" do
    given(:user) { FactoryGirl.create(:user, :email_confirmed) }

    it "shows no flash" do
      expect(page).to_not have_flash :warning
    end
  end  

  it "contains the user's full name and email" do
    within('.main') do
      expect(page).to have_content user.name
      expect(page).to have_content user.email
    end
  end

  it "contains a link to the name change page" do
    expect(page).to have_link links[:name_change], href: new_name_change_path
  end

  it "contains a link to the email change page" do
    expect(page).to have_link links[:email_change], href: '#'
  end

  it "contains a link to the password change page" do
    expect(page).to have_link links[:password_change], href: new_password_change_path
  end

  it "contains a link to the password recovery page" do
    expect(page).to have_link links[:password_reset], href: new_password_reset_path
  end

  it "contains a locale selector" do
    expect(page).to have_selector('#locale-selector')
  end
end