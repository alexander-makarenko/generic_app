require 'rails_helper'

feature "Signin" do
  given(:not_activated_user) { FactoryGirl.create(:user) }
  given(:activated_user)     { FactoryGirl.create(:user, :activated) }
  given(:nonexistent_user)   { FactoryGirl.build(:user) }
  background { visit signin_path }
  
  specify "page" do
    expect(page).to have_selector('h1', text: 'Sign in')
  end

  context "with invalid data" do
    background { sign_in_as(nonexistent_user) }
    
    it "does not sign the user in" do
      expect(page).to have_link('Sign in')
      expect(page).to_not have_link('Sign out')
    end

    it "re-renders current page" do
      expect(page).to have_selector('h1', text: 'Sign in')
    end

    it "displays flash message" do
      expect(page).to have_flash(:error, 'Invalid')
    end
  end

  context "with valid data" do
    context "as non-activated user" do
      background { sign_in_as(not_activated_user) }

      it "does not sign the user in" do
        expect(page).to have_link('Sign in')
        expect(page).to_not have_link('Sign out')
      end

      it "displays flash message" do
        expect(page).to have_flash(:alert, 'not activated')
      end
    end
    
    context "as activated user" do
      let(:keep_signed_in) { Hash[ keep_signed_in: false ] }
      background { sign_in_as(activated_user, keep_signed_in) }

      it "signs the user in" do
        expect(page).to_not have_link('Sign in')
        expect(page).to have_link('Sign out')
      end

      it "displays flash message" do
        expect(page).to have_flash(:success, 'have signed in')
      end

      feature "and keep me signed in" do
        background do
          expire_session_cookies
          visit root_path
        end
  
        context "not checked" do
          it "forgets user after browser reopening" do
            expect(page).to have_link('Sign in')
            expect(page).to_not have_link('Sign out')
          end
        end

        context "checked" do
          let(:keep_signed_in) { Hash[ keep_signed_in: true ] }
          
          it "remembers user after browser reopening" do
            expect(page).to_not have_link('Sign in')
            expect(page).to have_link('Sign out')
          end
        end
      end
    end    
  end
end

feature "Signout" do
  given(:activated_user) { FactoryGirl.create(:user, :activated) }
  background do
    visit signin_path
    sign_in_as(activated_user)
    click_link('Sign out')
  end

  it "signs the user out" do    
    expect(page).to have_link('Sign in')
    expect(page).to_not have_link('Sign out')
  end
    
  it "redirects to home page" do
    expect(current_path).to eq(root_path)
  end

  it "displays flash message" do
    expect(page).to have_flash(:notice, 'have signed out')
  end
end