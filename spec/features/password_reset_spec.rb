require 'rails_helper'

feature "Password" do
  given(:user) { FactoryGirl.create(:user) }
  given(:nonexistent_user) { FactoryGirl.build(:user) }
  given(:forgot_password_link) { t 'v.sessions.new.password_reset' }
  given(:settings_link) { t 'v.layouts._header.nav_links.settings' }
  given(:form_heading) { t 'v.password_resets.new.heading' }

  given(:info_box) { '.main .alert-info' }
  given(:success_box) { '.main .alert-success' }
  given(:danger_box) { '.main .alert-danger' }
  
  background do
    visit signin_path
    first(:link, forgot_password_link).click
  end

  feature "reset" do
    feature "form" do
      given(:email_field_value) { page.find('#password_reset_email').value }

      it "has a proper heading" do
        expect(page).to have_selector 'h2', text: form_heading
      end

      context "when the user is not signed in" do
        it "has an empty email field" do
          expect(email_field_value).to be_nil
        end
      end

      context "when the user is signed in" do
        background do
          visit signin_path
          sign_in_as user
          page.find('#accountDropdown').click
          click_link settings_link
          click_link forgot_password_link
        end
        
        it "has the email field pre-filled" do
          expect(email_field_value).to eq user.email
        end
      end
    end
    
    feature "request" do
      background { request_password_reset(email: email) }

      context "with an email of invalid format" do
        given(:email) { 'invalid' }

        it "re-renders the page" do
          expect(page).to have_selector 'h2', text: form_heading
        end

        it "shows validation errors" do
          expect(page).to have_selector '.validation-errors'
        end
      end

      context "with an email that does not exist" do
        given(:email) { nonexistent_user.email }

        it "does not send password reset instructions" do
          expect(deliveries).to be_empty
        end

        it "re-renders the page" do
          expect(page).to have_selector 'h2', text: form_heading
        end

        it "shows validation errors" do
          expect(page).to have_selector '.validation-errors'
        end
      end

      context "with a correct email" do
        given(:email) { user.email }
        given(:instructions_sent) do
          t('c.password_resets.instructions_sent', email: email)
        end
        
        it "sends password reset instructions" do
          expect(deliveries.count).to eq 1
        end

        it "redirects to the home page" do
          expect(current_path).to eq root_path
        end

        it "shows an appropriate flash" do
          expect(page).to have_selector(info_box, text: instructions_sent)
        end
      end
    end

    feature "link" do
      given(:get_new_link) { t 'c.password_resets.get_new_link' }
      given(:link_invalid) { t 'c.password_resets.link_invalid', get_new_link: get_new_link }
      given(:link_expired) { t 'c.password_resets.link_expired', get_new_link: get_new_link }
      given(:hashed_email) { get_hashed_email_from password_reset_link }
      given(:token)        { get_token_from password_reset_link }
      
      subject { password_reset_link(hashed_email: hashed_email, token: token) }

      background { request_password_reset(email: user.email) }

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
          Timecop.travel 4.hours
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
        background { visit subject }

        it "redirects to the password update page" do
          expect(current_path).to eq edit_password_path(hashed_email: hashed_email, token: token)
        end

        context "when visited again after the password has been successfully reset" do
          background do
            set_password(password: 'new_password')
            visit subject
          end

          it "redirects to the home page" do
            expect(current_path).to eq root_path
          end

          it "shows an appropriate flash" do
            expect(page).to have_selector(danger_box, text: link_expired)
          end
        end
      end
    end
  end

  feature "update" do
    given(:form_heading) { t 'v.password_resets.edit.heading' }

    subject { set_password(password: new_password) }

    background do
      request_password_reset(email: user.email)
      visit password_reset_link
    end

    it "page has a proper heading" do
      expect(page).to have_selector 'h2', text: form_heading
    end

    context "with invalid data" do
      given(:new_password) { ' ' }
      
      background { subject }

      it "re-renders the page" do
        expect(page).to have_selector 'h2', text: form_heading
      end
      
      it "shows validation errors" do
        expect(page).to have_selector '.validation-errors'
      end
    end

    context "with valid data" do
      given(:signout_link) { t 'v.layouts._header.nav_links.sign_out' }
      given(:signin_link) { t 'v.layouts._header.nav_links.sign_in' }
      given(:password_changed) { t 'c.password_resets.password_changed' }
      given(:new_password) { 'new_password' }

      background { subject }

      it "signs the user in" do
        expect(page).to have_no_link(signin_link).and have_link(signout_link)
      end

      it "shows an appropriate flash" do
        expect(page).to have_selector(success_box, text: password_changed)
      end
    end
  end
end