require 'rails_helper'

feature "Email change" do
  given(:user) { FactoryGirl.create(:user, :email_confirmed) }
  given(:original_email) { user.email }
  given(:account_link) { t 'v.layouts._header.nav_links.settings' }
  given(:email_change_link) { t 'v.users.show.email_change' }
  given(:form_heading) { t 'v.email_changes.new.heading' }

  background do
    visit signin_path
    sign_in_as user
    click_link account_link
    within('.account-settings .email') { click_link email_change_link }
  end

  it "page has a proper heading" do
    expect(page).to have_selector 'h2', text: form_heading
  end
  
  feature "request" do
    subject { change_email(new_email: new_email, current_password: user.password) }

    context "on submission of invalid data" do
      given(:new_email) { 'invalid@email' }
      
      background { subject }

      it "does not update the user's email" do
        click_link account_link
        within '.main' do
          expect(page).to have_content original_email
          expect(page).to_not have_content new_email
        end
      end

      it "does not send a confirmation email" do
        expect(deliveries).to be_empty
      end

      it "re-renders the page" do
        expect(page).to have_selector 'h2', text: form_heading
      end

      it "shows validation errors" do
        expect(page).to have_selector '.validation-errors'
      end
    end

    context "on submission of valid data" do
      given(:new_email) { 'new.email@example.com' }
      given(:confirmation_email_sent) do
        t('c.email_changes.create.success', email: new_email)
      end

      it "updates the user's email" do
        subject
        within '.main' do
          expect(page).to have_content new_email
          expect(page).to_not have_content original_email
        end
      end

      it "sends two emails, one to the user's new email, the other - to the original one" do
        expect { subject }.to change(deliveries, :count).from(0).to(2)

        emails = deliveries.inject([]) { |memo, mail| memo << mail.to }.flatten

        expect(emails).to include(original_email).and include(new_email)
      end

      it "redirects to the profile page of the current user" do
        subject
        expect(current_path).to match account_path
      end

      it "shows an appropriate flash" do
        subject
        expect(page).to have_flash :success, confirmation_email_sent
      end
    end

    context "when cancelled" do
      context "before the form has been submitted" do
        given(:cancel_link) { t 'v.email_changes.new.cancel' }
        
        background { click_link cancel_link }

        it "redirects to the profile page of the current user" do
          expect(current_path).to match account_path
        end
      end

      context "after the form has been submitted" do
        given(:cancel_link) { t 'c.users.show.cancel' }
        given(:request_cancelled) { t'c.email_changes.destroy.info' }
        given(:new_email) { 'new.email@example.com' }
        
        background do
          subject
          visit current_path
          click_link cancel_link
        end

        it "redirects to the profile page of the current user" do
          expect(current_path).to match account_path
        end

        it "restores the user's original email address" do
          within '.main' do
            expect(page).to have_content original_email
            expect(page).to_not have_content new_email
          end
        end

        it "shows an appropriate flash" do
          expect(page).to have_flash :info, request_cancelled
        end
      end
    end
  end
end