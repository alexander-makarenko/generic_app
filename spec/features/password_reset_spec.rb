require 'rails_helper'

feature "Password" do
  given(:user)             { FactoryGirl.create(:user) }
  given(:nonexistent_user) { FactoryGirl.build(:user) }
  background do
    visit signin_path
    click_link('Forgot')
  end

  feature "reset" do
    specify "page" do
      expect(page).to have_selector('h1', text: 'Reset password')
    end

    feature "request" do
      context "with email of invalid format" do
        background { request_password_reset('not.an@email') }

        it "re-renders current page" do
          expect(page).to have_selector('h1', text: 'Reset password')
        end

        it "displays validation errors" do
          expect(page).to have_content('error')
        end
      end

      context "with email that does not exist" do
        background { request_password_reset(nonexistent_user.email) }

        it "does not send password reset link" do
          expect(deliveries).to be_empty
        end

        it "redirects to home page" do
          expect(current_path).to eq(root_path)
        end

        it "displays flash message" do
          expect(page).to have_flash(:notice, 'reset instructions')
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

        it "displays flash message" do
          expect(page).to have_flash(:notice, 'reset instructions')
        end
      end
    end

    feature "link" do
      background { request_password_reset(user.email) }

      context "with missing token" do
        # write this test after implementing Routing Error handler
        # (the user will probably see the 404 error)
      end
      
      context "with invalid token" do
        background { visit password_reset_link(with: :invalid_token) }

        it "redirects to home page" do
          expect(current_path).to eq(root_path)
        end

        it "displays flash message" do
          expect(page).to have_flash(:error, 'is invalid')
        end
      end
      
      context "with missing encoded email" do
        background { visit password_reset_link(with: :no_encoded_email) }
        
        it "redirects to home page" do
          expect(current_path).to eq(root_path)
        end

        it "displays flash message" do
          expect(page).to have_flash(:error, 'is invalid')
        end
      end

      context "with invalid encoded email" do
        # write this test after implementing BadRequest handling
        # (the user will probably be redirected somewhere)
      end

      context "that has expired" do
        background do
          persisted_user = User.find_by(email: user.email)
          persisted_user.update_attribute(:password_reset_email_sent_at, 4.hours.ago)
          visit password_reset_link
        end

        it "redirects to home page" do
          expect(current_path).to eq(root_path)
        end

        it "displays flash message" do
          expect(page).to have_flash(:error, 'has expired')
        end    
      end

      context "that is valid" do
        background { visit password_reset_link }

        it "redirects to password update page" do
          expect(current_path).to match(edit_password_path(''))
        end
      end
    end
  end

  feature "update" do
    background do
      request_password_reset(user.email)
      visit password_reset_link
    end

    specify "page" do
      expect(page).to have_selector('h1', text: 'Change password')
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

      it "does not clear user's password_reset_email_sent_at attribute" do
        expect(user.reload.password_reset_email_sent_at).to_not be_nil
      end

      it "re-renders current page" do
        expect(page).to have_selector('h1', text: 'Change password')
      end

      it "displays validation errors" do
        expect(page).to have_content('error')
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

      it "clears user's password_reset_email_sent_at attribute" do
        expect(user.reload.password_reset_email_sent_at).to be_nil
      end

      it "redirects to signin page" do
        expect(current_path).to eq(signin_path)
      end

      it "displays flash message" do
        expect(page).to have_flash(:success, 'successfully updated')
      end
    end
  end
end