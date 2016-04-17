require 'rails_helper'

describe "The profile page" do
  let(:user) { FactoryGirl.create(:user, last_seen_at: 2.hour.ago) }

  before do
    visit signin_path
  end

  context "when it belongs to the user themselves" do
    let(:account_page_heading) { t 'v.users.show.heading' }
    let(:settings_link) { t 'v.layouts._header.nav_links.settings' }
    let(:name_change_link) { t 'v.users.show.name_change' }
    let(:email_change_link) { t 'v.users.show.email_change' }
    let(:password_change_link) { t 'v.users.show.password_change' }
    let(:password_recovery_link) { t 'v.users.show.password_reset' }
    let(:warning_box) { '.main .alert-warning' }

    before do
      sign_in_as user
      page.find('#accountDropdown').click
      click_link settings_link
    end

    it "has a proper heading" do
      expect(page).to have_selector 'h2', text: account_page_heading
    end

    context "when the user did not confirm their email" do
      let(:get_confirmation_link) { t 'c.users.show.confirm' }

      context "and did not request a confirmation link" do
        let(:email_not_confirmed) do
          t('c.users.show.email_not_confirmed', link: get_confirmation_link)
        end

        it "has an appropriate flash" do
          expect(page).to have_selector(warning_box, text: email_not_confirmed)
        end
      end

      context "and has requested a confirmation link" do
        let(:get_new_confirmation_link) { t 'c.users.show.here' }
        let(:confirmation_sent) do
          t('c.users.show.confirmation_sent', email: user.email,
            link: get_new_confirmation_link)
        end

        before do
          click_link get_confirmation_link
          visit current_path
        end

        it "has an appropriate flash" do
          expect(page).to have_selector(warning_box, text: confirmation_sent)
        end
      end

      context "and has requested their email to be changed" do
        let(:new_email) { 'new.email@example.com' }
        let(:email_change_pending) do
          t('c.users.show.email_change_pending', email: new_email,
            resend_link: t('c.users.show.resend'), cancel_link: t('c.users.show.cancel'))
        end

        before do
          within('#accountSettings .email') { click_link email_change_link }
          change_email(new_email: new_email, current_password: user.password)
          visit current_path
        end

        it "has an appropriate flash" do
          expect(page).to have_selector(warning_box, text: email_change_pending)
        end
      end
    end

    context "when the user has confirmed their email" do
      let(:user) { FactoryGirl.create(:user, :email_confirmed) }

      it "has no flash" do
        expect(page).to_not have_selector(warning_box)
      end
    end

    it "contains the user's full name" do
      within('.main') { expect(page).to have_content user.name }
    end

    it "contains the user's email" do
      within('.main') { expect(page).to have_content user.email }
    end

    it "contains the user's avatar" do
      expect(page).to have_selector '#avatar'
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

  context "when it belongs to another user" do
    context "and is visited by a regular user" do
      let(:another_user) { FactoryGirl.create(:user) }

      before do
        sign_in_as user
        visit user_path(id: another_user.id)
      end

      it "redirects to the home page" do
        expect(current_path).to eq root_path
      end
    end

    context "and is visited by an admin user" do
      let(:admin) { FactoryGirl.create(:user, :admin) }
      let(:role) { t('v.users.show_admin.admin') }
      let(:email_status) { t('v.users.show_admin.email_status') }      
      let(:confirmation_email_status) { t('v.users.show_admin.email_confirmation_sent_at') }
      let(:locale_name) { t("v.shared._locale_selector.#{user.locale}") }
      
      before do
        sign_in_as admin
        visit user_path(id: user.id)
      end

      it "has a proper heading"do      
        expect(page).to have_selector 'h2', text: t('v.users.show_admin.heading')
      end

      it "contains the user's avatar" do
        expect(page).to have_selector '#avatar'
      end

      feature "table" do
        given(:table) { find('table#userInfo') }

        scenario "lists the user's full name" do
          expect(table).to have_content user.name
        end

        scenario "lists the user's email" do
          expect(table).to have_content user.email
        end

        scenario "lists the user's email status" do
          expect(table).to have_content email_status
        end

        scenario "lists the user's confirmation email status" do
          expect(table).to have_content confirmation_email_status
        end

        scenario "lists the name of the user's locale" do
          expect(table).to have_content locale_name
        end

        scenario "lists the user's registration date" do
          expect(table).to have_content user.created_at
        end

        scenario "lists the user's last seen at time" do
          expect(table).to have_content (/#{t('h.users_helper.ago')}/)
        end

        scenario "lists the user's role" do
          expect(table).to have_content role
        end
      end
    end
  end
end