require 'rails_helper'

describe "User profile page" do
  let(:user) { FactoryGirl.create(:user) }
  let(:account_link) { t 'v.layouts._header.nav_links.settings' }
  let(:name_change_link) { t 'v.users.show.name_change' }
  let(:email_change_link) { t 'v.users.show.email_change' }
  let(:password_change_link) { t 'v.users.show.password_change' }
  let(:password_recovery_link) { t 'v.users.show.password_reset' }
  let(:account_page_heading) { t 'v.users.show.heading' }

  before do
    visit signin_path
    sign_in_as user
    click_link account_link
  end
  
  it "has a proper heading" do
    expect(page).to have_selector 'h2', text: account_page_heading
  end

  context "when the email is not confirmed" do
    let(:get_confirmation_link) { t 'c.users.show.confirm' }

    context "and a confirmation link has not been requested" do
      let(:email_not_confirmed) do
        t('c.users.show.email_not_confirmed', link: get_confirmation_link)
      end

      it "shows an appropriate flash" do
        expect(page).to have_flash :warning, email_not_confirmed
      end
    end

    context "after a confirmation link has been requested" do
      let(:get_new_confirmation_link) { t 'c.users.show.here' }
      let(:confirmation_sent) do
        t('c.users.show.confirmation_sent', email: user.email,
          link: get_new_confirmation_link)
      end

      before do
        click_link get_confirmation_link
        visit current_path
      end

      it "shows an appropriate flash" do
        expect(page).to have_flash :warning, confirmation_sent
      end
    end

    context "after an email change has been requested" do
      let(:new_email) { 'new.email@example.com' }      
      let(:email_change_pending) do
        t('c.users.show.email_change_pending', email: new_email,
          resend_link: t('c.users.show.resend'), cancel_link: t('c.users.show.cancel'))
      end

      before do
        within('.account-settings .email') { click_link email_change_link }        
        change_email(new_email: new_email, current_password: user.password)
        visit current_path
      end

      it "shows an appropriate flash" do
        expect(page).to have_flash :warning, email_change_pending
      end
    end
  end

  context "when the email is confirmed" do
    let(:user) { FactoryGirl.create(:user, :email_confirmed) }

    it "shows no flash" do
      expect(page).to_not have_flash :warning
    end
  end

  it "contains the user's full name" do
    within('.main') { expect(page).to have_content user.name }
  end

  it "contains the user's email" do
    within('.main') { expect(page).to have_content user.email }
  end

  it "contains a link to the name change page" do
    expect(page).to have_link name_change_link, href: new_name_change_path
  end

  it "contains a link to the email change page" do
    expect(page).to have_link email_change_link, href: new_email_change_path
  end

  it "contains a link to the password change page" do
    expect(page).to have_link password_change_link, href: new_password_change_path
  end

  it "contains a link to the password recovery page" do
    expect(page).to have_link password_recovery_link, href: new_password_reset_path
  end

  it "contains a locale selector" do
    expect(page).to have_selector '#locale-selector'
  end
end