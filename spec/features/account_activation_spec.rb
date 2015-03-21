require 'rails_helper'

feature "Activation" do
  given(:user) { FactoryGirl.build(:user) }  
  background do
    visit signup_path
    sign_up_as(user)
  end

  feature "link" do
    given(:persisted_user) { User.find_by(email: user.email) }

    context "that is invalid" do      
      background do
        visit link(:activation, hashed_email: 'invalid', token: 'invalid')
      end

      it "does not activate user" do
        expect(persisted_user).to_not be_activated
      end

      it "does not set activation time" do
        expect(persisted_user.activated_at).to be_nil
      end

      it "does not clear activation_sent_at attribute" do
        expect(persisted_user.activation_sent_at).to_not be_nil
      end
      
      it "redirects to home page" do
        expect(current_path).to eq(root_path)
      end

      it "displays flash" do
        expect(page).to have_flash :error,
          t('c.account_activations.edit.flash.error.invalid',
            link: t('c.account_activations.edit.flash.link'))
      end
    end
    
    context "that has expired" do
      background do        
        persisted_user.update_attribute(:activation_sent_at, 1.week.ago)
        visit link(:activation)
      end

      it "does not activate user" do
        expect(persisted_user.reload).to_not be_activated
      end

      it "does not set activation time" do
        expect(persisted_user.reload.activated_at).to be_nil
      end

      it "does not clear activation_sent_at attribute" do
        expect(persisted_user.reload.activation_sent_at).to_not be_nil
      end

      it "redirects to home page" do
        expect(current_path).to eq(root_path)
      end

      it "displays flash" do
        expect(page).to have_flash :error,
          t('c.account_activations.edit.flash.error.expired',
            link: t('c.account_activations.edit.flash.link'))
      end
    end

    context "that is valid" do
      background { visit link(:activation) }

      context "when account is not activated" do
        it "activates the user" do
          expect(persisted_user).to be_activated
        end

        it "sets activation time" do
          expect(persisted_user.activated_at).to_not be_nil
        end

        it "clears user's activation_sent_at attribute" do
          expect(persisted_user.activation_sent_at).to be_nil
        end

        it "redirects to home page" do
         expect(current_path).to eq(root_path)
        end

        it "displays flash" do
          expect(page).to have_flash :success,
            t('c.account_activations.edit.flash.success')
        end
      end

      context "when account is already activated" do
        background { visit link(:activation) }

        it "redirects to home page" do
          expect(current_path).to eq(root_path)
        end

        it "displays flash" do
          expect(page).to have_flash :error,            
            t('c.account_activations.already_activated')
        end
      end
    end
  end

  feature "rerequest" do
    given(:persisted_user) { User.find_by(email: user.email) }

    background do
      visit link(:activation, hashed_email: 'invalid', token: 'invalid')      
      within('.flash') { click_link t('c.account_activations.edit.flash.link') }
    end

    describe "page" do
      it "has correct header" do
        expect(page).to have_selector 'h1',
          text: t('v.account_activations.new.header')
      end

      it "has user email pre-filled" do
        expect(page.find('#email').value).to eq(user.email)
      end
    end

    context "with incorrect password" do
      background { rerequest_account_activation_as(user, password: 'incorrect') }

      it "does not send activation link" do
        expect(deliveries.count).to eq(1)
      end

      it "re-renders the page" do
        expect(page).to have_selector 'h1',
          text: t('v.account_activations.new.header')
      end

      it "displays flash" do
        expect(page).to have_flash :error,
          t('c.account_activations.create.flash.error')
      end
    end

    context "with invalid email" do
      background { rerequest_account_activation_as(user, email: 'not_an@email') }

      it "does not update user's email" do
        expect(persisted_user.email).to eq(user.email)
      end

      it "does not send activation link" do
        expect(deliveries.count).to eq(1)
      end

      it "re-renders the page" do
        expect(page).to have_selector 'h1',
          text: t('v.account_activations.new.header')
      end

      it "displays email validation errors" do
        within('div.validation-errors') do
          expect(page).to have_content('email')        # to do: use I18n translation
          expect(page).to_not have_content('password') # to do: use I18n translation
        end        
      end      
    end

    context "with valid data" do
      let(:new_email) { user.email.prepend('new_') }
      background do
        rerequest_account_activation_as(user, email: new_email)
      end

      it "updates user's email" do
        expect(persisted_user.email).to eq(new_email)
      end

      it "sends account activation link" do
        expect(deliveries.count).to eq(2)
      end

      it "redirects to home page" do
        expect(current_path).to eq(root_path)
      end

      it "displays flash" do
        expect(page).to have_flash :notice,
          t('c.account_activations.create.flash.notice')
      end
    end
  end
end