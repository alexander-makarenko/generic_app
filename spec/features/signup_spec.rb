require 'rails_helper'

feature "Signup form" do
  given(:user) { FactoryGirl.build(:user) }
  given(:heading) { t 'v.users.new.heading' }

  background { visit signup_path }

  specify "has a proper heading" do
    expect(page).to have_selector 'h2', text: heading
  end
  
  context "on typing invalid data", :js do
    background { fill_in 'user_email', with: 'invalid' }

    it "shows validation errors" do
      expect(page).to have_selector '.validation-errors'
    end

    it "removes validation errors when corrected" do
      fill_in 'user_email', with: user.email
      expect(page).to_not have_selector '.validation-errors'
    end
  end

  feature "on submission" do
    def submit
      sign_up_as user
    end

    context "with invalid data" do
      given(:user) { FactoryGirl.build(:user, :invalid) }

      it "does not save the user" do
        expect { submit }.to_not change(User, :count)
      end

      it "does not send a welcome email" do
        expect { submit }.to_not change(deliveries, :count)
      end

      it "re-renders the page" do
        submit
        expect(page).to have_selector 'h2', text: heading
      end

      it "shows validation errors" do
        submit
        expect(page).to have_selector '.validation-errors'
      end
    end

    context "with valid data" do
      given(:signout_link) { t 'v.layouts._header.nav_links.sign_out' }
      given(:signin_link) { t 'v.layouts._header.nav_links.sign_in' }

      it "saves the user" do
        expect { submit }.to change(User, :count).from(0).to(1)
      end

      it "signs the user in" do
        submit
        expect(page).to have_no_link(signin_link).and have_link(signout_link)
      end

      it "sends a welcome email" do
        expect { submit }.to change(deliveries, :count).from(0).to(1)
      end

      it "redirects to the home page" do
        submit
        expect(current_path).to eq root_path
      end
    end
  end
end