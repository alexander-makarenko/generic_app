require 'rails_helper'

feature "Password" do
  given(:user)             { FactoryGirl.create(:user) }
  given(:nonexistent_user) { FactoryGirl.build(:user) }
  background do
    visit signin_path
    click_link t('v.sessions.new.password_reset')
  end

  feature "reset" do
    it "form has a proper heading" do
      expect(page).to have_selector 'h2', text: t('v.password_resets.new.header')
    end
    
    feature "request" do
      context "with an email of invalid format" do
        background { request_password_reset('not.an@email') }

        it "re-renders the page" do
          expect(page).to have_selector('h2',
            text: t('v.password_resets.new.header'))
        end

        it "shows validation errors" do
          expect(page).to have_selector('.validation-errors')
        end
      end

      context "with an email that does not exist" do
        background { request_password_reset(nonexistent_user.email) }

        it "does not send a password reset link" do
          expect(deliveries).to be_empty
        end

        it "re-renders the page" do
          expect(page).to have_selector('h2',
            text: t('v.password_resets.new.header'))
        end

        it "shows validation errors" do
          expect(page).to have_selector('.validation-errors')
        end        
      end

      context "with a correct email" do
        background { request_password_reset(user.email) }
        
        it "sends a password reset link" do
          expect(deliveries.count).to eq(1)
        end

        it "redirects to the home page" do
          expect(current_path).to eq root_path
        end

        it "shows an appropriate flash" do
          expect(page).to have_flash :info, t('c.password_resets.create.info')
        end
      end
    end

    feature "link" do
      background { request_password_reset(user.email) }

      context "with an invalid hashed email" do
        let(:token) { extract_token(link(:password_reset)) }
        before { visit link(:password_reset, hashed_email: 'invalid', token: token) }

        it "redirects to the home page" do
          expect(current_path).to eq root_path
        end

        it "shows an appropriate flash" do
          expect(page).to have_flash :danger,
            t('c.password_resets.edit.invalid',
              link: t('c.password_resets.edit.link'))
        end
      end

      context "with an invalid token" do
        let(:hashed_email) { extract_hashed_email(link(:password_reset)) }
        before { visit link(:password_reset, hashed_email: hashed_email, token: 'invalid') }

        it "redirects to the home page" do
          expect(current_path).to eq root_path
        end

        it "shows an appropriate flash" do
          expect(page).to have_flash :danger,
            t('c.password_resets.edit.invalid', link: t('c.password_resets.edit.link'))
        end
      end

      context "that has expired" do
        background do
          Timecop.travel(4.hours)
          visit link(:password_reset)
        end

        it "redirects to the home page" do
          expect(current_path).to eq root_path
        end

        it "shows an appropriate flash" do
          expect(page).to have_flash :danger,
            t('c.password_resets.edit.expired',
              link: t('c.password_resets.edit.link'))
        end
      end

      context "that is valid" do
        let(:hashed_email) { extract_hashed_email(link(:password_reset)) }
        let(:token)        { extract_token(link(:password_reset)) }
        background { visit link(:password_reset) }

        it "redirects to the password update page" do
          expect(current_path).to eq(edit_password_path(hashed_email: hashed_email, token: token))
        end

        context "when visited again after the password has been successfully reset" do
          background do            
            update_password_with(
              password: 'new_password',
              confirmation: 'new_password')
            visit link(:password_reset)    
          end

          it "redirects to the home page" do
            expect(current_path).to eq root_path
          end

          it "shows an appropriate flash" do
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

    it "page has a proper heading" do
      expect(page).to have_selector 'h2',
        text: t('v.password_resets.edit.header')
    end    

    context "with invalid data" do
      background do
        update_password_with(password: '', confirmation: 'mismatch')        
      end

      it "does not update the user's password" do
        expect(user.password_digest).to eql(user.reload.password_digest)
      end

      it "does not clear the user's password_reset_sent_at attribute" do
        expect(user.reload.password_reset_sent_at).to_not be_nil
      end

      it "re-renders the page" do
        expect(page).to have_selector 'h2', text: t('v.password_resets.edit.header')
      end
      
      it "shows validation errors" do
        expect(page).to have_selector('.validation-errors')
      end
    end

    context "with valid data" do
      background do
        update_password_with(password: 'new_password', confirmation: 'new_password')
      end

      it "updates the user's password" do
        expect(user.password_digest).to_not eql(user.reload.password_digest)
      end

      it "clears the user's password_reset_sent_at attribute" do
        expect(user.reload.password_reset_sent_at).to be_nil
      end

      it "redirects to the signin page" do
        expect(current_path).to eq(signin_path)
      end

      it "shows an appropriate flash" do
        expect(page).to have_flash :success, t('c.password_resets.update.success')
      end
    end
  end
end