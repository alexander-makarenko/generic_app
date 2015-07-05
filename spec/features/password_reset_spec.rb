require 'rails_helper'

feature "Password" do
  given(:user)             { FactoryGirl.create(:user) }
  given(:nonexistent_user) { FactoryGirl.build(:user) }
  background do
    visit signin_path
    click_link t('v.sessions.new.password_reset')
  end

  feature "reset" do
    it "form has correct header" do
      expect(page).to have_selector 'h2', text: t('v.password_resets.new.header')
    end
    
    feature "request" do
      context "with email of invalid format" do
        background { request_password_reset('not.an@email') }

        it "re-renders page" do
          expect(page).to have_selector('h2',
            text: t('v.password_resets.new.header'))
        end

        it "shows validation errors" do
          expect(page).to have_selector('.validation-errors')
        end
      end

      context "with email that does not exist" do
        background { request_password_reset(nonexistent_user.email) }

        it "does not send password reset link" do
          expect(deliveries).to be_empty
        end

        it "re-renders page" do
          expect(page).to have_selector('h2',
            text: t('v.password_resets.new.header'))
        end

        it "shows validation errors" do
          expect(page).to have_selector('.validation-errors')
        end        
      end

      context "with correct email" do
        background { request_password_reset(user.email) }
        
        it "sends password reset link" do
          expect(deliveries.count).to eq(1)
        end

        it "redirects to home page" do
          expect(current_path).to eq(localized_root_path(locale: I18n.locale))
        end

        it "displays flash" do
          expect(page).to have_flash :info,
            t('c.password_resets.create.info')
        end
      end
    end

    feature "link" do
      background { request_password_reset(user.email) }

      context "with invalid hashed email" do
        let(:token) { extract_token(link(:password_reset)) }
        before { visit link(:password_reset, hashed_email: 'invalid', token: token) }

        it "redirects to home page" do
          expect(current_path).to eq(localized_root_path(locale: I18n.locale))
        end

        it "displays flash" do
          expect(page).to have_flash :danger,
            t('c.password_resets.edit.invalid',
              link: t('c.password_resets.edit.link'))
        end
      end

      context "with invalid token" do
        let(:hashed_email) { extract_hashed_email(link(:password_reset)) }
        before { visit link(:password_reset, hashed_email: hashed_email, token: 'invalid') }

        it "redirects to home page" do
          expect(current_path).to eq(localized_root_path(locale: I18n.locale))
        end

        it "displays flash" do
          expect(page).to have_flash :danger,
            t('c.password_resets.edit.invalid',
              link: t('c.password_resets.edit.link'))
        end
      end

      context "that has expired" do        
        background do
          Timecop.travel(4.hours)          
          visit link(:password_reset)
        end

        it "redirects to home page" do
          expect(current_path).to eq(localized_root_path(locale: I18n.locale))
        end

        it "displays flash" do
          expect(page).to have_flash :danger,
            t('c.password_resets.edit.expired',
              link: t('c.password_resets.edit.link'))
        end
      end

      context "that is valid" do
        let(:hashed_email) { extract_hashed_email(link(:password_reset)) }
        let(:token)        { extract_token(link(:password_reset)) }
        background { visit link(:password_reset) }

        it "redirects to password update page" do
          expect(current_path).to eq(
            edit_password_path(locale: I18n.locale, hashed_email: hashed_email, token: token))
        end

        context "when visited again after password was successfully reset" do
          background do            
            update_password_with(
              password: 'new_password',
              confirmation: 'new_password')
            visit link(:password_reset)    
          end

          it "redirects to home page" do
            expect(current_path).to eq(localized_root_path(locale: I18n.locale))
          end

          it "displays flash" do
            expect(page).to have_flash :danger,
              t('c.password_resets.edit.expired',
                link: t('c.password_resets.edit.link'))
          end
        end
      end
    end
  end

  feature "update" do
    background do
      request_password_reset(user.email)
      visit link(:password_reset)
    end

    it "has proper header" do
      expect(page).to have_selector 'h2',
        text: t('v.password_resets.edit.header')
    end    

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

      it "re-renders page" do
        expect(page).to have_selector 'h2',
          text: t('v.password_resets.edit.header')
      end
      
      it "shows validation errors" do
        expect(page).to have_selector('.validation-errors')
      end
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
        expect(current_path).to eq(signin_path(locale: I18n.locale))
      end

      it "displays flash" do
        expect(page).to have_flash :success,
          t('c.password_resets.update.success')
      end
    end
  end
end