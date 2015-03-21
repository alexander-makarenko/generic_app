require 'rails_helper'

feature "Password" do
  given(:user)             { FactoryGirl.create(:user) }
  given(:nonexistent_user) { FactoryGirl.build(:user) }
  background do
    visit signin_path
    click_link t('v.sessions.new.forgot?')
  end

  feature "reset" do
    include_examples "page has", h1: t('v.password_resets.new.header')
    
    feature "request" do
      context "with email of invalid format" do
        background { request_password_reset('not.an@email') }

        include_examples "page has", h1: t('v.password_resets.new.header')
        include_examples "page has validation errors"
      end

      context "with email that does not exist" do
        background { request_password_reset(nonexistent_user.email) }

        it "does not send password reset link" do
          expect(deliveries).to be_empty
        end

        include_examples "page has", h1: t('v.password_resets.new.header')

        it "displays flash" do
          expect(page).to have_flash :error,
            t('c.password_resets.create.flash.error')
        end
      end

      context "with correct email" do
        background { request_password_reset(user.email) }
        
        it "sends password reset link" do
          expect(deliveries.count).to eq(1)
        end

        it "redirects to home page" do
          expect(current_path).to eq(root_path)
        end

        it "displays flash" do
          expect(page).to have_flash :notice,
            t('c.password_resets.create.flash.notice')
        end
      end
    end

    feature "link" do
      background { request_password_reset(user.email) }

      context "that is invalid" do
        background do
          visit link(:password_reset, hashed_email: 'invalid', token: 'invalid')
        end

        it "redirects to home page" do
          expect(current_path).to eq(root_path)
        end

        it "displays flash" do
          expect(page).to have_flash :error,
            t('c.password_resets.edit.flash.error.invalid',
              link: t('c.password_resets.edit.flash.link'))
        end
      end

      context "that has expired" do
        let(:persisted_user) { User.find_by(email: user.email) }
        background do
          persisted_user.update_attribute(:password_reset_sent_at, 4.hours.ago)
          visit link(:password_reset)
        end

        it "redirects to home page" do
          expect(current_path).to eq(root_path)
        end

        it "displays flash" do
          expect(page).to have_flash :error,
            t('c.password_resets.edit.flash.error.expired',
              link: t('c.password_resets.edit.flash.link'))
        end
      end

      context "that is valid" do
        let(:hashed_email) { extract_hashed_email(link(:password_reset)) }
        let(:token)        { extract_token(link(:password_reset)) }
        background { visit link(:password_reset) }

        it "redirects to password update page" do
          expect(current_path).to eq(
            edit_password_path(hashed_email: hashed_email, token: token))
        end
      end
    end
  end

  feature "update" do
    background do
      request_password_reset(user.email)
      visit link(:password_reset)
    end

    include_examples "page has", h1: t('v.password_resets.edit.header')

    context "with invalid data" do
      background do
        update_password_with(
          password: '',
          confirmation: 'mismatch')
      end

      it "does not update user's password" do
        expect(user.password_digest).to eql(user.reload.password_digest)
      end

      it "does not clear user's password_reset_sent_at attribute" do
        expect(user.reload.password_reset_sent_at).to_not be_nil
      end

      include_examples "page has", h1: t('v.password_resets.edit.header')
      include_examples "page has validation errors"
    end

    context "with valid data" do
      background do
        update_password_with(
          password: 'new_password',
          confirmation: 'new_password')
      end

      it "updates user's password" do
        expect(user.password_digest).to_not eql(user.reload.password_digest)
      end

      it "clears user's password_reset_sent_at attribute" do
        expect(user.reload.password_reset_sent_at).to be_nil
      end

      it "redirects to signin page" do
        #=======================================================
        # replace with "expect(current_path).to eq(signin_path)" after
        # removing the "default_url_options" method from application_controller
        #=======================================================
        expect(current_path).to eq(signin_path(locale: 'en'))
      end

      it "displays flash" do
        expect(page).to have_flash :success,
          t('c.password_resets.update.flash.success')
      end
    end
  end
end