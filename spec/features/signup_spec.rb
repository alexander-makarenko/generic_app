require 'rails_helper'

feature "Signup form" do
  given(:user)         { FactoryGirl.build(:user) }
  given(:invalid_user) { FactoryGirl.build(:user, :invalid) }
  background { visit signup_path }

  specify "has a proper heading" do
    expect(page).to have_selector('form h3', text: t('v.users.new.header'))
  end
  
  context "on typing invalid data", js: true do
    background { fill_in 'user_email', with: invalid_user.email }

    it "shows validation errors and removes them when corrected" do      
      expect(page).to have_selector('.validation-errors')
      fill_in 'user_email', with: user.email
      expect(page).to have_no_selector('.validation-errors')
    end
  end
  
  feature "on submission" do
    context "with invalid data" do
      background(submit_before: true) { sign_up_as(invalid_user) }
      
      it "does not save the user" do
        expect { sign_up_as(invalid_user) }.to_not change(User, :count)
      end

      it "does not send a welcome email" do
        expect { sign_up_as(invalid_user) }.to_not change(deliveries, :count)
      end

      it "re-renders the page", submit_before: true do
        expect(page).to have_selector('form h3', text: t('v.users.new.header'))
      end

      it "shows validation errors", submit_before: true do
        expect(page).to have_selector('.validation-errors')
      end
    end

    context "with valid data" do
      background(submit_before: true) { sign_up_as(user) }

      it "saves the user" do
        expect { sign_up_as(user) }.to change(User, :count).from(0).to(1)
      end

      include_examples "the user is signed in", submit_before: true

      it "sends a welcome email" do
        expect { sign_up_as(user) }.to change(deliveries, :count).from(0).to(1)
      end

      it "redirects to the home page", submit_before: true do
        expect(current_path).to eq root_path
      end
    end
  end
end