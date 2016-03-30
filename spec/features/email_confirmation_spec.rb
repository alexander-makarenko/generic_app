require 'rails_helper'

feature "Email confirmation" do
  given(:user) { FactoryGirl.create(:user) }
  given(:settings_link) { t 'v.layouts._header.nav_links.settings' }
  given(:sign_out_link) { t 'v.layouts._header.nav_links.sign_out' }
  given(:get_confirmation_link) { t 'c.users.show.confirm' }
  given(:get_new_confirmation_link) { t 'c.email_confirmations.get_new_link' }

  given(:success_box) { '.main .alert-success' }
  given(:warning_box) { '.main .alert-warning' }
  given(:danger_box) { '.main .alert-danger' }

  background do
    visit signin_path
    sign_in_as user
    page.find('#accountDropdown').click
    click_link settings_link
    within('.alert') { click_link get_confirmation_link }
  end

  subject { email_confirmation_link(hashed_email: hashed_email, token: token) }

  feature "request" do
    given(:email_sent) { t('c.email_confirmations.email_sent', email: user.email) }

    it "redirects to the profile page of the current user" do
      expect(current_path).to match account_path
    end

    it "shows an appropriate flash" do
      expect(page).to have_selector(success_box, text: email_sent)
      expect(page).to_not have_selector(warning_box)
    end
  end

  feature "link" do
    given(:link_invalid) do
      t('c.email_confirmations.link_invalid', get_new_link: get_new_confirmation_link)
    end
    given(:link_expired) do
      t('c.email_confirmations.link_expired', get_new_link: get_new_confirmation_link)
    end
    given(:hashed_email) { get_hashed_email_from email_confirmation_link }
    given(:token)        { get_token_from email_confirmation_link }

    context "with an invalid hashed email" do
      given(:hashed_email) { 'invalid' }
      
      background { visit subject }
      
      it "redirects to the home page" do
        expect(current_path).to eq root_path
      end

      it "shows an appropriate flash" do
        expect(page).to have_selector(danger_box, text: link_invalid)
      end
    end

    context "with an invalid token" do
      given(:token) { 'invalid' }
      
      background { visit subject }

      it "redirects to the home page" do
        expect(current_path).to eq root_path
      end

      it "shows an appropriate flash" do
        expect(page).to have_selector(danger_box, text: link_invalid)
      end
    end

    context "that has expired" do
      background do
        Timecop.travel 1.week
        visit subject
      end

      it "redirects to the home page" do
        expect(current_path).to eq root_path
      end

      it "shows an appropriate flash" do
        expect(page).to have_selector(danger_box, text: link_expired)
      end
    end

    context "that is valid" do
      context "when the user is signed in" do
        background { visit subject }

        it "redirects to the profile page of the current user" do
          expect(current_path).to match account_path
        end
      end

      context "when the user is not signed in" do
        background do
          click_link sign_out_link
          visit subject
        end

        it "redirects to the home page" do
          expect(current_path).to eq root_path
        end
      end

      context "when the user has a pending email change" do
        given(:email_change_link) { t 'v.users.show.email_change' }
        given(:new_email) { 'new.email@example.com' }
        given(:email_changed) do
          t('c.email_confirmations.email_changed', email: user.reload.email)
        end

        background do
          within('#accountSettings .email') { click_link email_change_link }          
          change_email(new_email: new_email, current_password: user.password)
          visit subject
        end

        it "shows an appropriate flash" do
          expect(page).to have_selector(success_box, text: email_changed)
        end
      end

      context "when the user does not have a pending email change" do
        given(:email_confirmed) do
          t('c.email_confirmations.email_confirmed', email: user.email)
        end

        background { visit subject }

        it "shows an appropriate flash" do
          expect(page).to have_selector(success_box, text: email_confirmed)
        end
      end
    end
  end

  feature "rerequest" do
    given(:hashed_email) { 'invalid' }
    given(:token) { 'invalid' }
    
    background do
      visit subject
      within('.alert') { click_link get_new_confirmation_link }
    end

    it "redirects to the profile page of the current user" do
      expect(current_path).to match account_path
    end
  end
end