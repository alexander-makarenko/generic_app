require 'rails_helper'
include ActionView::Helpers::DateHelper

feature "Email confirmation" do
  given(:user) { FactoryGirl.create(:user) }
  background do
    visit signin_path
    sign_in_as(user)    
    click_link t('v.layouts._header.nav_links.settings')
    within('.alert-warning') { click_link t('c.users.show.flash.link') }
  end

  shared_examples "redirects to home page" do
    it "redirects to home page" do
      expect(current_path).to eq(localized_root_path(locale: I18n.locale))
    end
  end

  shared_examples "redirects to current user profile page" do
    it "redirects to current user profile page" do
      expect(current_path).to match(account_path)
    end
  end

  feature "request" do
    include_examples "redirects to current user profile page"    

    it "displays flash, which changes to more relevant after 5 minutes" do
      expect(page).to have_flash :warning, t('c.users.show.flash.warning.2',
        link: t('c.users.show.flash.link'))

      Timecop.travel(6.minutes)
      visit account_path

      expect(page).to have_flash :warning, t('c.users.show.flash.warning.3',
        link: t('c.users.show.flash.link'),
        time_ago: time_ago_in_words(user.reload.email_confirmation_sent_at))
    end
  end  

  feature "link" do
    subject(:persisted_user) { User.find_by(email: user.email) }

    context "with invalid hashed email" do
      let(:token) { extract_token(link(:email_confirmation)) }
      before { visit link(:email_confirmation, hashed_email: 'invalid', token: token) }

      it "does not update user's email confirmation related attributes" do
        expect(subject.email_confirmed).to be false
        expect(subject.email_confirmed_at).to be_nil
        expect(subject.email_confirmation_sent_at).to_not be_nil
      end

      include_examples "redirects to home page"

      it "displays flash" do
        expect(page).to have_flash :danger,
          t('c.email_confirmations.edit.flash.danger.invalid',
            link: t('c.email_confirmations.edit.flash.link'))
      end
    end

    context "with invalid token" do
      let(:hashed_email) { extract_hashed_email(link(:email_confirmation)) }
      before { visit link(:email_confirmation, hashed_email: hashed_email, token: 'invalid') }

      it "does not update user's email confirmation related attributes" do
        expect(subject.email_confirmed).to be false
        expect(subject.email_confirmed_at).to be_nil
        expect(subject.email_confirmation_sent_at).to_not be_nil
      end

      include_examples "redirects to home page"

      it "displays flash" do
        expect(page).to have_flash :danger,
          t('c.email_confirmations.edit.flash.danger.invalid',
            link: t('c.email_confirmations.edit.flash.link'))
      end
    end

    context "that has expired" do
      before do
        subject.update_attribute(:email_confirmation_sent_at, 1.week.ago)
        visit link(:email_confirmation)
        subject.reload
      end
    
      it "does not update user's email confirmation related attributes" do
        expect(subject.email_confirmed).to be false
        expect(subject.email_confirmed_at).to be_nil
        expect(subject.email_confirmation_sent_at).to_not be_nil
      end

      include_examples "redirects to home page"

      it "displays flash" do
        expect(page).to have_flash :danger,
          t('c.email_confirmations.edit.flash.danger.expired',
            link: t('c.email_confirmations.edit.flash.link'))
      end
    end

    context "that is valid" do
      shared_examples "shared" do
        it "updates user's email confirmation related attributes" do
          expect(subject.email_confirmed).to be true
          expect(subject.email_confirmed_at).to_not be_nil
          expect(subject.email_confirmation_sent_at).to be_nil
        end

        it "displays flash" do
          expect(page).to have_flash :success,
            t('c.email_confirmations.edit.flash.success')
        end
      end

      context "when user is signed in" do
        before { visit link(:email_confirmation) }

        include_examples "shared"
        include_examples "redirects to current user profile page" 
      end

      context "when user is not signed in" do
        before do
          click_link t('v.layouts._header.nav_links.sign_out')
          visit link(:email_confirmation)
        end

        include_examples "shared"
        include_examples "redirects to home page"
      end
    end
  end

  feature "rerequest" do
    context "when user is signed in" do
      background do
        visit link(:email_confirmation, hashed_email: 'invalid', token: 'invalid')
        within('.alert') { click_link t('c.email_confirmations.edit.flash.link') }
      end
      
      include_examples "redirects to current user profile page" 
    end

    context "when user is not signed in" do
      before do
        click_link t('v.layouts._header.nav_links.sign_out')
        visit link(:email_confirmation, hashed_email: 'invalid', token: 'invalid')
        within('.alert') { click_link t('c.email_confirmations.edit.flash.link') }
      end
      
      include_examples "redirects to home page"
    end
  end
end