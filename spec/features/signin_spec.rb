require 'rails_helper'

feature "Signin" do
  given(:user) { FactoryGirl.create(:user) }
  given(:nonexistent_user) { FactoryGirl.build(:user) }
  given(:heading) { t 'v.sessions.new.heading' }
  given(:signin_link) { t 'v.layouts._header.nav_links.sign_in' }
  given(:signout_link) { t 'v.layouts._header.nav_links.sign_out' }
  given(:users_link) { t 'v.layouts._header.nav_links.users' }
  given(:error_message) { t 'c.sessions.invalid_credentials' }

  given(:navbar) { 'header nav' }
  given(:footer) { 'footer' }
  given(:account_dropdown) { '#accountDropdown' }
  given(:locale_selector)  { '#locale-selector' }

  shared_examples "navigation bar changes as expected" do |user_role|
    scenario "navigation bar changes as expected" do
      within(navbar) do
        expect(page).to have_no_link(signin_link)
        expect(page).to (user_role.try(:to_sym) == :admin ? have_link(users_link) : have_no_link(users_link))
        expect(page).to have_content(user.name)
        find(account_dropdown).click
        expect(page).to have_link(signout_link)
      end
    end
  end

  shared_examples "navigation bar doesn't change" do
    scenario "navigation bar doesn't change" do
      within(navbar) do
        expect(page).to have_link(signin_link)
        expect(page).to_not have_link(signout_link)
      end
    end
  end

  shared_examples "footer changes as expected" do
    scenario "footer changes as expected" do
      within(footer) do
        expect(page).to have_no_selector(locale_selector)
      end
    end
  end

  shared_examples "footer doesn't change" do
    scenario "footer doesn't change" do
      within(footer) do
        expect(page).to have_selector(locale_selector)
      end
    end
  end

  shared_examples "keep me signed in option" do
    feature "keep me signed in option" do
      context "if not checked" do
        background do
          sign_in_as(user)
          expire_session_cookies
          visit root_path
        end
        
        scenario "the user gets signed out after they reopen the browser" do
          within(navbar) do
            expect(page).to have_link(signin_link)
            expect(page).to_not have_link(signout_link)
          end
        end
      end

      context "if checked" do
        background do
          sign_in_as(user, keep_signed_in: true)
          expire_session_cookies
          visit root_path
        end

        scenario "the user stays signed in after they reopen the browser" do
          within(navbar) do
            expect(page).to_not have_link(signin_link)
            expect(page).to have_link(signout_link)
          end
        end
      end
    end
  end

  background do
    visit root_path
    within(navbar) { click_link(signin_link) }
  end

  context "JS disabled" do
    given(:error_box) { '.main .alert-danger' }

    feature "page" do
      scenario "has proper appearance" do
        expect(page).to have_selector('h2', text: heading)
      end
    end

    feature "form is submitted with invalid credentials" do
      background do
        sign_in_as(nonexistent_user)
      end

      include_examples "navigation bar doesn't change"

      include_examples "footer doesn't change"

      scenario "the user stays on the same page" do
        expect(page).to have_selector('h2', text: heading)
      end

      scenario "an error appears" do
        expect(page).to have_selector(error_box, text: error_message)
      end
    end

    feature "form is submitted with valid credentials" do
      background do
        sign_in_as(user)
      end

      context "that belong to a regular user" do
        include_examples "navigation bar changes as expected"
      end

      context "that belong to an admin user" do
        given(:user) { FactoryGirl.create(:user, :admin) }

        include_examples "navigation bar changes as expected", :admin
      end

      include_examples "footer changes as expected"

      scenario "the user is redirected to the home page" do
        expect(current_path).to eq root_path
      end
    end

    it_has_behavior "keep me signed in option" 
  end

  context "JS enabled", :js do
    given(:modal) { '#signinModal' }
    given(:modal_header) { '.modal-header' }
    given(:modal_error) { '.modal-body .alert-danger' }
    given(:close_button) { 'button.close' }
    given(:opened_modal_indicator) { '.modal-open' }

    feature "modal" do
      scenario "appears when the respective link on the navbar is clicked" do
        expect(page).to have_selector(opened_modal_indicator)
      end

      feature "does not appear on certain pages" do
        scenario "signin page" do
          visit signin_path
          within(navbar) { click_link(signin_link) }
          expect(page).to_not have_selector(opened_modal_indicator)
        end

        scenario "signup page" do
          visit signup_path
          within(navbar) { click_link(signin_link) }
          expect(page).to_not have_selector(opened_modal_indicator)
        end
      end

      scenario "has proper appearance" do
        within(modal) do
          expect(page).to have_selector(modal_header, text: heading)
        end
      end
    end

    feature "form is submitted with invalid credentials" do
      given(:submit_button) { t('v.sessions.new.submit_button') }

      background do
        sign_in_as(nonexistent_user, modal: true)
        wait_for_ajax
      end

      include_examples "navigation bar doesn't change"

      include_examples "footer doesn't change"

      scenario "an error appears in the modal" do
        within(modal) do
          expect(page).to have_selector(modal_error, text: error_message)
        end
      end

      scenario "the error is not duplicated when the form is submitted again" do
        click_button submit_button
        wait_for_ajax
        within(modal) do
          expect(page).to have_selector(modal_error, count: 1)
        end
      end

      scenario "the error is cleared when the modal is reopened" do
        within(modal) do
          find(close_button).click
        end
        expect(page).to_not have_selector(opened_modal_indicator)
        within(navbar) { click_link(signin_link) }
        within(modal) do
          expect(page).to_not have_selector(modal_error, text: error_message)
        end
      end
    end

    feature "form is submitted with valid credentials" do
      background do
        sign_in_as(user, modal: true)
        wait_for_ajax
      end

      context "that belong to a regular user" do
        include_examples "navigation bar changes as expected"
      end

      context "that belong to an admin user" do
        given(:user) { FactoryGirl.create(:user, :admin) }

        include_examples "navigation bar changes as expected", :admin
      end

      include_examples "footer changes as expected"
    end
  end

  it_has_behavior "keep me signed in option"
end