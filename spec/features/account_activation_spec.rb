require 'rails_helper'

feature "Account activation" do
  given(:user) { FactoryGirl.build(:user) }
  given(:nonexistent_user) { FactoryGirl.build(:user) }
  background do
    visit signup_path
    sign_up_as(user)
  end

  feature "link" do
    context "with missing token" do
      # write this test after implementing Routing Error handler
      # (the user will probably see the 404 error)
    end

    context "with invalid token" do
      background { visit activation_link(with: :invalid_token) }

      it "redirects to home page" do
        expect(current_path).to eq(root_path)
      end

      it "displays flash message" do
        expect(page).to have_flash(:error, 'is invalid')
      end
    end

    context "with missing encoded email" do
      background { visit activation_link(with: :no_encoded_email) }
      
      it "redirects to home page" do
        expect(current_path).to eq(root_path)
      end
      
      it "displays flash message" do
        expect(page).to have_flash(:error, 'is invalid')
      end
    end

    context "with invalid encoded email" do
      # write this test after implementing BadRequest handler
      # (the user will probably be redirected somewhere)
    end

    context "that has expired" do
      background do
        persisted_user = User.find_by(email: user.email)
        persisted_user.update_attribute(:activation_email_sent_at, 1.week.ago)
        visit activation_link
      end

      it "redirects to home page" do
        expect(current_path).to eq(root_path)
      end
    
      it "displays flash message" do
        expect(page).to have_flash(:error, 'has expired')
      end
    end

    context "that is valid" do
      background { visit activation_link }

      it "redirects to signin page" do
        expect(current_path).to eq(signin_path)
      end

      it "displays flash message" do
        expect(page).to have_flash(:success, 'Thank you for confirming')
      end
    end
  end

  feature "re-request" do
    background  do
      visit activation_link(with: :invalid_token)
      within('.flash') { click_link('here') }
    end
  
    specify "page" do
      expect(page).to have_selector('h1', text: 'Request activation email')
    end

    context "with invalid data" do
      background { rerequest_activation_email_as(nonexistent_user) }

      it "does not send activation link" do
        expect(deliveries.count).to eq(1)
      end

      it "re-renders current page" do
        expect(page).to have_selector('h1', text: 'Request activation email')
      end

      it "displays flash message" do
        expect(page).to have_flash(:error, 'Invalid')
      end      
    end

    context "with valid data" do
      background { rerequest_activation_email_as(user) }

      it "sends activation link" do
        expect(deliveries.count).to eq(2)
      end

      it "redirects to home page" do
        expect(current_path).to eq(root_path)
      end

      it "displays flash message" do
        expect(page).to have_flash(:notice, 'activation email has been sent')
      end
    end
  end
end