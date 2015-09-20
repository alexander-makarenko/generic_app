require 'rails_helper'

feature "Signin" do
  given(:user) { FactoryGirl.create(:user) }
  given(:nonexistent_user) { FactoryGirl.build(:user) }
  given(:keep_signed_in) { false}
  given(:signin_link) { t 'v.layouts._header.nav_links.sign_in' }
  given(:signout_link) { t 'v.layouts._header.nav_links.sign_out' }
  given(:form_heading) { t 'v.sessions.new.heading' }
  
  subject { sign_in_as(user, keep_signed_in: keep_signed_in) }

  background { visit signin_path }
  
  specify "form has a proper heading" do
    expect(page).to have_selector 'form h3', text: form_heading
  end
  
  context "with invalid data" do
    given(:user) { nonexistent_user }
    given(:invalid_credentials) { t 'c.sessions.invalid_credentials' }

    background { subject }

    it "does not sign the user in" do
      expect(page).to have_link(signin_link).and have_no_link(signout_link)
    end

    it "shows the user's name in the header" do
      expect(page).to_not have_selector 'header nav li', text: user.name
    end

    it "re-renders the page" do
      expect(page).to have_selector 'form h3', text: form_heading
    end

    it "shows an appropriate flash" do
      expect(page).to have_flash :danger, invalid_credentials
    end
  end

  context "with valid data" do
    background { subject }

    it "signs the user in" do
      expect(page).to have_no_link(signin_link).and have_link(signout_link)
    end

    it "redirects to the home page" do
      expect(current_path).to eq root_path
    end

    it "shows the user's name in the header" do
      expect(page).to have_selector 'header nav li', text: user.name
    end

    feature "and keep me signed in" do
      background do
        expire_session_cookies
        visit root_path
      end

      context "not checked, after browser reopening" do
        it "does not sign the user in" do
          expect(page).to have_link(signin_link).and have_no_link(signout_link)
        end
      end

      context "checked, after browser reopening" do
        let(:keep_signed_in) { true }

        it "signs the user in" do
          expect(page).to have_no_link(signin_link).and have_link(signout_link)
        end
      end
    end
  end
end