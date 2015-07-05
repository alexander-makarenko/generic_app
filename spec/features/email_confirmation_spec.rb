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

  shared_examples "redirects to home page" do
    it "redirects to home page" do
      expect(current_path).to eq(localized_root_path(locale: I18n.locale))
    end
  end

  shared_examples "redirects to profile page of current user" do
    it "redirects to profile page of current user" do
      expect(current_path).to match(account_path)
    end
  end

  feature "request" do
    include_examples "redirects to profile page of current user"
  end

  feature "link" do
    subject(:persisted_user) { User.find_by(email: user.email) }

    context "that is invalid" do
      shared_examples "shared" do
        it "does not update user's email confirmation related attributes" do
          expect(subject.email_confirmed).to be false
          expect(subject.email_confirmed_at).to be_nil
          expect(subject.email_confirmation_sent_at).to_not be_nil
        end

        include_examples "redirects to home page"

        it "shows appropriate flash" do
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

        it "updates user's email confirmation related attributes" do
          expect(subject.email_confirmed).to be true
          expect(subject.email_confirmed_at).to_not be_nil
          expect(subject.email_confirmation_sent_at).to be_nil
        end

        it "shows appropriate flash" do
          expect(page).to have_flash :success, message
        end
      end

      context "when user is signed in" do
        before { visit link(:email_confirmation) }

        include_examples "shared"
        include_examples "redirects to profile page of current user" 
      end

      context "when user is not signed in" do
        before do
          click_link links[:sign_out]
          visit link(:email_confirmation)
        end

        include_examples "shared"
        include_examples "redirects to home page"
      end
    end
  end

  feature "rerequest" do
    given(:invalid_confirmation_link) { link(:email_confirmation, hashed_email: 'invalid', token: 'invalid')}
    background do
      visit invalid_confirmation_link
      within('.alert') { click_link links[:resend_confirmation_email] }
    end

    include_examples "redirects to profile page of current user"
  end
end