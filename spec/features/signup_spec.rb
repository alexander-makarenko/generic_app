require 'rails_helper'

feature "Signup" do
  given(:user)         { FactoryGirl.build(:user) }
  given(:invalid_user) { FactoryGirl.build(:user, :invalid) }
  background { visit signup_path }

  specify "page" do
    expect(page).to have_selector('h1', text: 'Sign up')
  end

  context "with invalid data" do
    before(hook: true) { sign_up_as(invalid_user) }

    it "does not save user" do
      expect { sign_up_as(invalid_user) }.to_not change(User, :count)
    end

    it "does not send activation link" do
      expect { sign_up_as(invalid_user) }.to_not change(deliveries, :count)
    end

    it "re-renders current page", hook: true do
      expect(page).to have_selector('h1', text: 'Sign up')
    end

    it "displays validation errors", hook: true do
      expect(page).to have_content('error')    
    end
  end

  context "with valid data" do
    before(hook: true) { sign_up_as(user) }

    it "saves user" do
      expect { sign_up_as(user) }.to change(User, :count).from(0).to(1)
    end

    it "sends activation link" do
      expect { sign_up_as(user) }.to change(deliveries, :count).from(0).to(1)
    end

    it "redirects to home page", hook: true do
      expect(current_path).to eq(root_path)
    end
    
    it "displays flash message", hook: true do
      expect(page).to have_flash(:notice, 'activation email has been sent')
    end
  end
end