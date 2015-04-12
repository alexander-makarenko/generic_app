require 'rails_helper'

feature "Profile" do
  given(:user) { FactoryGirl.create(:user, :activated) }
  background do
    visit signin_path
    sign_in_as(user)
    #=======================================================
    # replace with "visit settings_path(user)"
    # after removing the "default_url_options" method from application_controller
    visit settings_path(id: user.id)
    #=======================================================
  end
  
  specify "update page has proper header" do
    expect(page).to have_selector 'h2', text: t('v.users.edit.header')    
  end

  feature "update" do
    context "with incorrect password" do
      background do
        update_profile_of(user, current_password: 'incorrect')
      end

      it "re-renders page" do
        expect(page).to have_selector 'h2', text: t('v.users.edit.header')
      end

      it "shows validation errors" do
        expect(page).to have_selector('.validation-errors')
      end
    end

    context "with correct password" do
      context "and invalid data" do
        background do
          update_profile_of(user,            
            email: 'invalid',
            current_password: user.password)
        end

        it "re-renders page" do
          expect(page).to have_selector 'h2', text: t('v.users.edit.header')
        end

        it "shows validation errors" do
          expect(page).to have_selector('.validation-errors')
        end
      end

      context "and valid data" do
        background do
          update_profile_of(user,
            last_name: 'Foo',
            email: 'foo@bar.com',
            current_password: user.password)
        end

        it "redirects to home page" do
          expect(current_path).to eq(root_path)
        end
        
        it "displays flash" do
          expect(page).to have_flash :success, t('c.users.update.flash.success')
        end
      end
    end
  end
end