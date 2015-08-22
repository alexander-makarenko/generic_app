require 'rails_helper'

feature "Email confirmation" do
  given(:user) { FactoryGirl.create(:user) }
  given(:links) { Hash[
    sign_out: t('v.layouts._header.nav_links.sign_out'),
    account_settings: t('v.layouts._header.nav_links.settings'),
    send_confirmation_email: t('c.users.show.link'),
    resend_confirmation_email: t('c.email_confirmations.edit.link')
  ] }

  background do
    visit signin_path
    sign_in_as(user)
    click_link links[:account_settings]
    within('.alert') { click_link links[:send_confirmation_email] }
  end

  shared_examples "redirects to the home page" do
    it "redirects to the home page" do
      expect(current_path).to eq root_path
    end
  end

  shared_examples "redirects to the profile page of the current user" do
    it "redirects to the profile page of the current user" do
      expect(current_path).to match(account_path)
    end
  end

  feature "request" do
    include_examples "redirects to the profile page of the current user"
  end

  feature "link" do
    subject { User.find_by(email: user.email) }

    context "that is invalid" do
      shared_examples "shared" do
        it "does not change the user's email status" do
          expect(subject.email_confirmed).to be false
        end

        include_examples "redirects to the home page"

        it "shows an appropriate flash" do
          expect(page).to have_flash :danger, message
        end
      end

      context "(invalid hashed email)" do
        let(:message) { t('c.email_confirmations.edit.invalid',
          link: links[:resend_confirmation_email]) }
        let(:token) { extract_token(link(:email_confirmation)) }
        before { visit link(:email_confirmation, hashed_email: 'invalid', token: token) }

        include_examples "shared"
      end

      context "(invalid token)" do
        let(:message) { t('c.email_confirmations.edit.invalid',
          link: links[:resend_confirmation_email]) }
        let(:hashed_email) { extract_hashed_email(link(:email_confirmation)) }
        before { visit link(:email_confirmation, hashed_email: hashed_email, token: 'invalid') }

        include_examples "shared"
      end

      context "(expired)" do
        let(:message) { t('c.email_confirmations.edit.expired',
          link: links[:resend_confirmation_email]) }
        before do
          Timecop.travel(1.week)
          visit link(:email_confirmation)
          subject.reload
        end

        include_examples "shared"
      end
    end

    context "that is valid" do
      shared_examples "shared" do
        let(:message) { t('c.email_confirmations.edit.success') }

        it "changes the user's email status to confirmed" do
          expect(subject.email_confirmed).to be true
        end

        it "shows an appropriate flash" do
          expect(page).to have_flash :success, message
        end
      end

      context "when the user is signed in" do
        before { visit link(:email_confirmation) }

        include_examples "shared"
        include_examples "redirects to the profile page of the current user"
      end

      context "when the user is not signed in" do
        before do
          click_link links[:sign_out]
          visit link(:email_confirmation)
        end

        include_examples "shared"
        include_examples "redirects to the home page"
      end
    end
  end

  feature "rerequest" do
    given(:invalid_confirmation_link) { link(:email_confirmation, hashed_email: 'invalid', token: 'invalid')}
    background do
      visit invalid_confirmation_link
      within('.alert') { click_link links[:resend_confirmation_email] }
    end

    include_examples "redirects to the profile page of the current user"
  end
end