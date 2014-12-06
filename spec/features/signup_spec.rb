require 'rails_helper'

feature "Signup" do
  given(:user)         { FactoryGirl.build(:user) }
  given(:invalid_user) { FactoryGirl.build(:user, :invalid) }
  background { visit signup_path }

  specify "page" do
    expect(page).to have_selector('h1', text: 'Sign up')
  end

  context "with invalid data" do
    it "does not save user" do
      expect { sign_up_as(invalid_user) }.to_not change(User, :count)
    end

    it "re-renders current page" do
      sign_up_as(invalid_user)
      expect(page).to have_selector('h1', text: 'Sign up')
    end

    it "displays validation errors" do
      sign_up_as(invalid_user)
      expect(page).to have_content('error')    
    end
  end

  context "with valid data" do
    it "saves user" do
      expect { sign_up_as(user) }.to change {
        [User.count, deliveries.count]
      }.from([0,0]).to([1,1])
    end
    
    it "redirects to home page" do
      sign_up_as(user)
      expect(current_path).to eq(root_path)
    end
    
    it "displays flash message" do
      sign_up_as(user)
      expect(page).to have_flash(:notice, 'activation email has been sent')
    end
  end
end