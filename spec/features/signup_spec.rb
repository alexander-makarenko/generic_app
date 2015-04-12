require 'rails_helper'

feature "Signup form" do
  given(:user)         { FactoryGirl.build(:user) }
  given(:invalid_user) { FactoryGirl.build(:user, :invalid) }
  background { visit signup_path }

  specify "has proper header" do
    expect(page).to have_selector('form h2', text: t('v.users.new.header'))
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
      
      it "does not save user" do
        expect { sign_up_as(invalid_user) }.to_not change(User, :count)
      end

      it "does not send activation link" do
        expect { sign_up_as(invalid_user) }.to_not change(deliveries, :count)
      end

      it "re-renders page", submit_before: true do
        expect(page).to have_selector('form h2', text: t('v.users.new.header'))
      end

      it "shows validation errors", submit_before: true do
        expect(page).to have_selector('.validation-errors')
      end
    end

    context "with valid data" do
      background(submit_before: true) { sign_up_as(user) }

      it "saves user" do
        expect { sign_up_as(user) }.to change(User, :count).from(0).to(1)
      end

      include_examples "user is signed in", submit_before: true

      it "sends activation link" do
        expect { sign_up_as(user) }.to change(deliveries, :count).from(0).to(1)
      end

      it "redirects to home page", submit_before: true do
        expect(current_path).to eq(root_path)
      end

      it "shows flash", submit_before: true do
        expect(page).to have_flash :info,
          t('c.users.create.flash.info', email: user.email)
      end
    end
  end
end